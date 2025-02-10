//
//  MainScreenViewModel.swift
//  Weather
//
//  Created by Gohar Vardanyan on 23.10.24.
//

import CoreLocation
import Combine
import RealmSwift
import SwiftUI
import FirebaseAuth

final class MainScreenViewModel: Reducer, ObservableObject {
    typealias State = MainScreenState
    
    var state: MainScreenState = MainScreenState()
    var cancelables: [AnyCancellable] = []

    @Dependency private var locationService: LocationServiceInterface
    @Dependency private var storageManager: StorageManagerInterface
    @Dependency private var networkService: NetworkServiceProtocol
    @Dependency private var auth: AuthInterface
    
    private var coordinator: (any CoordinatorInterface)?
    
    init(coordinator: any CoordinatorInterface) {
        self.coordinator = coordinator
        observableReducer()

        locationService.statusSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                self?.state.locationStatus = status
            }
            .store(in: &cancelables)
    }
    
    func send(_ action: Action) {
        switch action as? MainScreenAction {
        case .weatherSelected(let info):
            weatherSelected(with: info)
        case .citySelected(let city):
            citySelected(city)
        case .deleteButtonPressed(let info):
            deleteButtonPressed(info: info)
        case .addButtonPressed(let info):
            addButtonPressed(info: info)
        case .searchWith(let query):
            searchWith(query: query)
        case .fetchWeatherInfo:
            Task {
                await fetchWeatherInfo()
            }
        case .requestNotificationPermission:
            requestNotificationPermission()
        default:
            break
        }
    }
    
    func weatherCardViewPresentationInfo(weatherInfo: WeatherCurrentInfo) -> WeatherCardViewInfo {
        let converter = WeatherInfoToPresentationInfoConverter(decimalPlaces: 0)
        return WeatherCardViewInfo(myLocation: converter.currentLocationTitle(isMyLocation: weatherInfo.isMyLocation,
                                                                              name: weatherInfo.currentWeather.name),
                                   location: weatherInfo.currentWeather.name,
                                   temperature: converter.convertTemperatureToText(temp: weatherInfo.currentWeather.main.temp,
                                                                                   unit: weatherInfo.unit),
                                   description: weatherInfo.currentWeather.weather.first?.main ?? "",
                                   tempRangeDescription: converter.temperatureRange(tempMax: weatherInfo.currentWeather.main.tempMax,
                                                                                    tempMin: weatherInfo.currentWeather.main.tempMin,
                                                                                    metric: weatherInfo.unit))
    }
    
    private func weatherSelected(with info: WeatherCurrentInfo) {
        let selectedCity = City(name: info.currentWeather.name,
                                lat: info.currentWeather.coord.lat,
                                lon: info.currentWeather.coord.lon)
        coordinator?.send(action: MainScreenAction.Delegate.pushForecastView(selectedCity, .overlayAdded, info))
    }
    
    private  func citySelected(_ city: City) {
        coordinator?.send(action: MainScreenAction.Delegate.pushForecastView(city, detailsViewPresentationStyle(selectedCity: city), nil))
    }
    
    private  func deleteButtonPressed(info: CurrentWeather) {
        guard let index = state.weatherInfo.firstIndex(where: { $0.currentWeather.name == info.name } ) else { return }
        let coordinates = StoreCoordinates(latitude: info.coord.lat,
                                           longitude: info.coord.lon,
                                           index: index - 1)
        storageManager.removeObject(with: auth.authenticatedUser?.uid,
                                                 info: coordinates)
        Task { @MainActor in
            state.weatherInfo.remove(at: index)
        }
    }
    
    private  func addButtonPressed(info: WeatherCurrentInfo) {
        let coordinates = StoreCoordinates(latitude: info.currentWeather.coord.lat,
                                           longitude: info.currentWeather.coord.lon,
                                           index: state.weatherInfo.count)
        storageManager.addItem(with: auth.authenticatedUser?.uid,
                                            info: coordinates)
        Task { @MainActor [weak self]  in
            self?.state.weatherInfo.append(info)
        }
    }
    
    private func searchWith(query: String)  {
        state.searchState = .searching
        let request = RequestFactory.locationSearchRequest(query)
        networkService.requestData(request, as: [City].self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                Task { @MainActor in
                    if case .failure(_) = completion {
                        self?.state.searchState = .failed
                    }
                }
            } receiveValue: { [weak self] info in
                Task { @MainActor in
                    self?.state.searchResult = info
                    self?.state.searchState = info.isEmpty ? .empty : .success
                }
            }
            .store(in: &cancelables)
    }
    
    private func fetchWeatherInfo() async {
        do {
            let coordinates = try await collectCoordinates()
            let firstWeatherTask = Task { try await self.fetchCurrentWeatherInfo(coordinate: coordinates.0,
                                                                                 isMyLocation: true) }
            let allWeatherDataTask = Task { try await fetchAllWeather(for: coordinates.1) }
            let firstWeatherData = try await firstWeatherTask.value
            Task { @MainActor in
                state.weatherInfo.append(firstWeatherData)
                state.fetchState = .succeed
            }
            
            let allWeatherData = try await allWeatherDataTask.value
            Task { @MainActor in
                state.weatherInfo.append(contentsOf: allWeatherData)
            }
        } catch {
            Task { @MainActor in
                state.fetchState = .failed(AppError.appError(error: error))
            }
        }
    }
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        }
    }
    
    private func getCurrentLocationInfo() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            var isResumed = false
            locationService.latestLocationObject
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: {  completion in
                    if case .failure(let error) = completion, !isResumed  {
                        let fetchError = AppError.appError(error: error)
                        continuation.resume(throwing: fetchError)
                    }
                    isResumed = true
                }, receiveValue: { location in
                    if !isResumed {
                        continuation.resume(returning: location)
                    }
                    isResumed = true
                    
                })
                .store(in: &cancelables)
            locationService.startTracking()
        }
    }
    
    private func collectCoordinates() async throws -> (Coordinates, [Coordinates]) {
        do {
            let locationInfo = try await getCurrentLocationInfo()
            let currentCoordinate = Coordinates(lon: locationInfo.coordinate.longitude,
                                                lat: locationInfo.coordinate.latitude)
            let storedCoordinates = storageManager.fetchStoredCoordinates(by: auth.authenticatedUser?.uid)
            return (currentCoordinate, storedCoordinates)
        } catch {
            throw AppError.locationFetchFail
        }
    }
    
    private func fetchAllWeather(for coordinates: [Coordinates]) async throws -> [WeatherCurrentInfo] {
        return try await withThrowingTaskGroup(of: (Int, WeatherCurrentInfo).self) { [weak self] group in
            guard let self else { return [] }
            for (index, coord) in coordinates.enumerated() {
                group.addTask {
                    let weatherInfo = try await self.fetchCurrentWeatherInfo(coordinate: coord)
                    return (index, weatherInfo)
                }
            }
            
            var weatherData: [(Int, WeatherCurrentInfo)] = []
            
            for try await (index, weather) in group {
                weatherData.append((index, weather))
            }
            
            return weatherData.sorted(by: { $0.0 < $1.0 }).map { $0.1 }
        }
    }
    
    private func fetchCurrentWeatherInfo(coordinate: Coordinates,
                                         isMyLocation: Bool = false) async throws -> WeatherCurrentInfo {
        do {
            let request =  RequestFactory.currentWeatherRequest(coordinates: coordinate)
            async let currentWeather = fetchWeatherInfo(request: request,
                                                        type: CurrentWeather.self)
            
            return WeatherCurrentInfo(currentWeather: try await currentWeather,
                                      unit: .celsius,
                                      isMyLocation: isMyLocation)
        } catch {
            throw AppError.appError(error: error)
        }
    }
    
    private func fetchWeatherInfo<T: Decodable> (request: NetworkRequest, type: T.Type) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            
            networkService.requestData(request, as: type)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(_) = completion {
                        continuation.resume(throwing: AppError.weatherFetchFail)
                    }
                } receiveValue: { response in
                    continuation.resume(returning: response)
                }
                .store(in: &cancelables)
        }
    }
    
    private  func detailsViewPresentationStyle(selectedCity: City) -> WeatherDetailsViewStyle  {
        let exist = state.weatherInfo.contains(where: { $0.currentWeather.name ==  selectedCity.name })
        return exist ? .overlayAdded : .overlay
    }
}

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

final class MainScreenViewModel: ObservableObject {
    @Published var searchState: SearchState?
    @Published var searchResult: [City] = []
    @Published var locationStatus: LocationAuthorizationStatus = .notDetermined
    @Published var fetchState: FetchState = .none
    @Published var weatherInfo: [WeatherCurrentInfo] = []
    
    private weak var coordinator: MainScreenCoordinatorInterface?
    private var dependencies: MainScreenDependenciesInterface
    private var cancelables: [AnyCancellable] = []
    
    init(coordinator: MainScreenCoordinatorInterface) {
        self.coordinator = coordinator
        self.dependencies = coordinator.dependenciesManager.createMainScreenDependencies()
        
        dependencies.locationService.statusSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                self?.locationStatus = status
            }
            .store(in: &cancelables)
    }
    
    func weatherSelected(with info: WeatherCurrentInfo) {
        let selectedCity = City(name: info.currentWeather.name,
                                lat: info.currentWeather.coord.lat,
                                lon: info.currentWeather.coord.lon)
        coordinator?.pushForecastView(selectedCity: selectedCity,
                                     style: .overlayAdded,
                                     currentInfo: info)
    }
    
    func citySelected(_ city: City) {
        coordinator?.pushForecastView(selectedCity: city,
                                     style: detailsViewPresentationStyle(selectedCity: city),
                                     currentInfo: nil)
        
    }
    
    func deleteButtonPressed(info: CurrentWeather) {
        guard let index = weatherInfo.firstIndex(where: { $0.currentWeather.name == info.name } ) else { return }
        let coordinates = StoreCoordinates(latitude: info.coord.lat,
                                           longitude: info.coord.lon,
                                           index: index - 1)
        dependencies.storageManager.removeObject(with: dependencies.auth.authenticatedUser?.uid,
                                                 info: coordinates)
        Task { @MainActor in
            weatherInfo.remove(at: index)
        }
    }
    
    func addButtonPressed(info: WeatherCurrentInfo) {
        let coordinates = StoreCoordinates(latitude: info.currentWeather.coord.lat,
                                           longitude: info.currentWeather.coord.lon,
                                           index: weatherInfo.count)
        dependencies.storageManager.addItem(with: dependencies.auth.authenticatedUser?.uid,
                                            info: coordinates)
        Task { @MainActor [weak self]  in
            self?.weatherInfo.append(info)
        }
    }
    
    func getCurrentLocationInfo() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            var isResumed = false
            dependencies.locationService.latestLocationObject
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
            dependencies.locationService.startTracking()
        }
    }
    
    func searchWith(query: String)  {
        searchState = .searching
        let request = RequestFactory.locationSearchRequest(query)
        dependencies.networkService.requestData(request, as: [City].self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                Task { @MainActor in
                    if case .failure(_) = completion {
                        self?.searchState = .failed
                    }
                }
            } receiveValue: { [weak self] info in
                Task { @MainActor in
                    self?.searchResult = info
                    self?.searchState = info.isEmpty ? .empty : .success
                }
            }
            .store(in: &cancelables)
    }
    
    func fetchWeatherInfo() async {
        do {
            let coordinates = try await collectCoordinates()
            let firstWeatherTask = Task { try await self.fetchCurrentWeatherInfo(coordinate: coordinates.0,
                                                                                 isMyLocation: true) }
            let allWeatherDataTask = Task { try await fetchAllWeather(for: coordinates.1) }
            let firstWeatherData = try await firstWeatherTask.value
            Task { @MainActor in
                weatherInfo.append(firstWeatherData)
                fetchState = .succeed
            }
            
            let allWeatherData = try await allWeatherDataTask.value
            Task { @MainActor in
                weatherInfo.append(contentsOf: allWeatherData)
            }
        } catch {
            Task { @MainActor in
                fetchState = .failed(AppError.appError(error: error))
            }
        }
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
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
    
    private func collectCoordinates() async throws -> (Coordinates, [Coordinates]) {
        do {
            let locationInfo = try await getCurrentLocationInfo()
            let currentCoordinate = Coordinates(lon: locationInfo.coordinate.longitude,
                                                lat: locationInfo.coordinate.latitude)
            let storedCoordinates = dependencies.storageManager.fetchStoredCoordinates(by: dependencies.auth.authenticatedUser?.uid)
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
            
            dependencies.networkService.requestData(request, as: type)
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
        let exist = weatherInfo.contains(where: { $0.currentWeather.name ==  selectedCity.name })
        return exist ? .overlayAdded : .overlay
    }
}

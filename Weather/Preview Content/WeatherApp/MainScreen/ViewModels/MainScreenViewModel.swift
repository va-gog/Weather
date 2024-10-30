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
    @Published var detailedViewStyle = WeatherDetailsViewStyle.dismissed
    @Published var locationStatus: LocationAuthorizationStatus = .notDetermined

    @Published var fetchState: FetchState = .none
    @Published var weatherInfo: [WeatherCurrentInfo] = []
    
    var addedWaetherInfo = PassthroughSubject<WeatherCurrentInfo, Never>()
    
    private var locationService: LocationServiceInterface
    private var storageManager: DataStorageManagerInterface
    private var networkManager: any NetworkManagerProtocol
    private var auth: AuthInterface
    private var cancellables: [AnyCancellable] = []
    
    init(locationService: LocationServiceInterface = LocationService(),
         storageManager: DataStorageManagerInterface = StorageManager(),
         networkManager: any NetworkManagerProtocol = NetworkManager(),
         auth: AuthInterface = AuthWrapper()) {
        self.locationService = locationService
        self.storageManager = storageManager
        self.networkManager = networkManager
        self.auth = auth
        
        addedWaetherInfo
            .sink { [weak self] value in
            guard let self else { return }
            
                let info = StoreCoordinates(latitude: value.currentWeather.coord.lat,
                                           longitude: value.currentWeather.coord.lon,
                                           index: self.weatherInfo.count)
                let newUserInfo = UserInfo(id: auth.currentUser?.uid ?? "")

                _ = storageManager.addOrUpdateItem(info: info,
                                               type: UserInfo.self, object: newUserInfo)
                Task { @MainActor in
                    self.weatherInfo.append(value)
                }
        }
        .store(in: &cancellables)
        
        locationService.statusSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
            self?.locationStatus = status
        }
        .store(in: &cancellables)

    }
    
    func itemSelected(name: String?)  {
      let exist = weatherInfo.contains(where: {$0.currentWeather.name == name })
        detailedViewStyle = exist ? .overlayAdded : .overlay
    }

    func getCurrentLocationInfo() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            var isResumed = false
            locationService.latestLocationObject
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: {  completion in
                    if case .failure(let error) = completion, !isResumed  {
                        let fetchError = AppError.convertToFetchError(error: error)
                        continuation.resume(throwing: fetchError)
                    }
                    isResumed = true
                }, receiveValue: { location in
                    if !isResumed {
                        continuation.resume(returning: location)
                    }
                    isResumed = true
                    
                })
                .store(in: &cancellables)
            locationService.startTracking()
        }
    }
    
    func searchWith(query: String)  {
        searchState = .searching
        let currentURL = WeatherURLBuilder.URLForGeo(geo: query)
        networkManager.fetchAndDecode(from: currentURL, as: [City].self)
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
            .store(in: &cancellables)

    }
    
    func fetchWeatherInfo() async {
        do {
            let coordinates = try await collectCoordinates()
            let firstWeatherTask = Task { try await self.fetchLocationWeatherInfo(coordinate: coordinates.0,
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
                fetchState = .failed(AppError.convertToFetchError(error: error))
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
            let object = storageManager.fetchItem(byId: auth.currentUser?.uid ?? "",
                                                  type: UserInfo.self)
            let coordinates = (object as? UserInfo)?.fetchStoredCoordinates() ?? []
            return (currentCoordinate, coordinates)
        } catch {
            throw AppError.locationFetchFail
        }
    }
    
    private func fetchAllWeather(for coordinates: [Coordinates]) async throws -> [WeatherCurrentInfo] {
        return try await withThrowingTaskGroup(of: (Int, WeatherCurrentInfo).self) { [weak self] group in
            guard let self else { return [] }
            for (index, coord) in coordinates.enumerated() {
                group.addTask {
                    let weatherInfo = try await self.fetchLocationWeatherInfo(coordinate: coord)
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
    
    private func fetchLocationWeatherInfo(coordinate: Coordinates,
                                                 isMyLocation: Bool = false) async throws -> WeatherCurrentInfo {
        do {
            let currentURL = WeatherURLBuilder.URLForCurrent(latitude: coordinate.lat,
                                                             longitude: coordinate.lon)
            async let currentWeather = fetchWeatherInfo(urlString: currentURL, type: CurrentWeather.self)
            
            return WeatherCurrentInfo(currentWeather: try await currentWeather,
                               unit: .celsius,
                               isMyLocation: isMyLocation)
        } catch {
            throw AppError.convertToFetchError(error: error)
        }
    }
    
    private func fetchWeatherInfo<T: Decodable> (urlString: String, type: T.Type) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in

            networkManager.fetchAndDecode(from: urlString , as: type)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(_) = completion {
                        continuation.resume(throwing: AppError.weatherFetchFail)
                    }
                } receiveValue: { response in
                    continuation.resume(returning: response)
                }
                .store(in: &cancellables)
        }
    }
}

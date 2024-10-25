//
//  MainScreenViewModel.swift
//  Weather
//
//  Created by Gohar Vardanyan on 23.10.24.
//

import CoreLocation
import Combine

final class MainScreenViewModel: ObservableObject {
    private var locationService: LocationServiceInterface
    private var storageManager: DataStorageManagerInterface
    private var networkManager: NetworkManagerProtocol
    private var cancellables: [AnyCancellable] = []
    
    @Published var searchState: SearchState?
    @Published var searchResult: [City] = []

    @Published var fetchState: FetchState = .none
    @Published var weatherInfo: [WeatherCurrentInfo] = []
    
    init(locationService: LocationServiceInterface = LocationService(),
         storageManager: DataStorageManagerInterface = DataStorageManager(),
         networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.locationService = locationService
        self.storageManager = storageManager
        self.networkManager = networkManager
    }
    
    func weatherCardViewPresentationInfo(weatherInfo: WeatherCurrentInfo) -> WeatherCardViewPresentationInfo {
        let converter = WeatherInfoToPresentationInfoConverter(decimalPlaces: 0)
        return WeatherCardViewPresentationInfo(myLocation: converter.currentLocationTitle(isMyLocation: weatherInfo.isMyLocation,
                                                                                          name: weatherInfo.currentWeather.name),
                                        location: weatherInfo.currentWeather.name,
                                               temperature: converter.convertTemperatureToText(temp: weatherInfo.currentWeather.main.temp,
                                                                                               unit: weatherInfo.unit),
                                               description: weatherInfo.currentWeather.weather.first?.main ?? "",
                                               tempRangeDescription: converter.temperatureRange(tempMax: weatherInfo.currentWeather.main.tempMax,
                                                                                                tempMin: weatherInfo.currentWeather.main.tempMin,
                                                                                                metric: weatherInfo.unit))
    }

    func getCurrentLocationInfo() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            locationService.latestLocationObject
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: {  completion in
                    if case .failure(let error) = completion {
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: { location in
                    continuation.resume(returning: location)
                })
                .store(in: &cancellables)
            locationService.startTracking()
        }
    }
    
    func search(query: String)  {
        searchState = .searching
        let currentURL = WeatherURLBuilder.URLForGeo(geo: query)
        networkManager.fetchAndDecode(from: currentURL, as: [City].self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                Task { @MainActor in
                    self?.searchState = completion == .finished ? .success : .failed
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
                fetchState = .failed(error)
            }
        }
    }
    
    private func collectCoordinates() async throws -> (CLLocationCoordinate2D, [CLLocationCoordinate2D]) {
        async let locationInfo = getCurrentLocationInfo()
        async let favWatherData = storageManager.fetchAddedWeatherCoordinates()
        return try await (locationInfo.coordinate, favWatherData)
    }
    
    
    private func fetchAllWeather(for coordinates: [CLLocationCoordinate2D]) async throws -> [WeatherCurrentInfo] {
        return try await withThrowingTaskGroup(of: WeatherCurrentInfo.self) { [weak self] group in
            guard let self else { return [] }
            var weatherData: [WeatherCurrentInfo] = []
            for coord in coordinates {
                group.addTask {
                    return try await self.fetchLocationWeatherInfo(coordinate: coord)
                }
            }
            
            for try await weather in group {
                weatherData.append(weather)
            }
            
            return weatherData
        }
    }
    
    private func fetchLocationWeatherInfo(coordinate: CLLocationCoordinate2D,
                                                 isMyLocation: Bool = false) async throws -> WeatherCurrentInfo {
        do {
            let currentURL = WeatherURLBuilder.URLForCurrent(latitude: coordinate.latitude,
                                                             longitude: coordinate.longitude)
            async let currentWeather = fetchWeatherInfo(urlString: currentURL, type: CurrentWeather.self)
            
            return WeatherCurrentInfo(currentWeather: try await currentWeather,
                               unit: .celsius,
                               isMyLocation: isMyLocation)
        } catch {
            throw error
        }
    }
    
    private func fetchWeatherInfo<T: Decodable> (urlString: String, type: T.Type) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in

            networkManager.fetchAndDecode(from: urlString , as: type)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        continuation.resume(throwing: error)
                    }
                } receiveValue: { response in
                    continuation.resume(returning: response)
                }
                .store(in: &cancellables)
        }
    }
}

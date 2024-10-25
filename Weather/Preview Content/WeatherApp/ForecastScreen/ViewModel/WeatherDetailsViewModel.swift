//
//  WeatherDetailsViewModel.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Foundation
import Combine
import CoreLocation

final class WeatherDetailsViewModel {
    private var networkManager: NetworkManagerProtocol
    private var cancellables: [AnyCancellable] = []
    var infoConverter = WeatherInfoToPresentationInfoConverter()
    
    var currentInfo: WeatherCurrentInfo
    @Published var forecastInfo = WeatherForecast(hourly: [], daily: [])
    @Published var fetchState: FetchState = .none
    
    init(networkManager: NetworkManagerProtocol = NetworkManager(), currentInfo: WeatherCurrentInfo) {
        self.networkManager = networkManager
        self.currentInfo = currentInfo
    }
    
    func fetchCurrentLocationWeatherInfo(coordinate: Coordinates) {
        let excludes = [OneCallApiExclude.current.rawValue, OneCallApiExclude.minutely.rawValue, OneCallApiExclude.alerts.rawValue]
        let forecastURL = WeatherURLBuilder.URLForForecast(latitude: coordinate.lat,
                                                           longitude: coordinate.lon,
                                                           exclude: excludes)
        networkManager.fetchAndDecode(from: forecastURL, as: WeatherForecast.self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.fetchState = .failed(error)
                }
            } receiveValue: { [weak self] forecast in
                self?.forecastInfo = forecast
            }
            .store(in: &cancellables)
    }
    
    func topViewPresentationInfo() -> TopViewPresentationInfo {
        TopViewPresentationInfo(name: infoConverter.currentLocationTitle(isMyLocation: currentInfo.isMyLocation,
                                                                         name: currentInfo.currentWeather.name),
                                temperature: infoConverter.convertTemperatureToText(temp: currentInfo.currentWeather.main.temp,
                                                                                    unit: currentInfo.unit),
                                isMyLocation: currentInfo.isMyLocation,
                                icon: weatherIcon(for: currentInfo.currentWeather.weather.first?.main ?? ""))
    }
    
    func hourlyViewPresentationInfo(index: Int) -> HourlyForecastViewPresentationInfo {
        let hourly = forecastInfo.hourly[index]
        return HourlyForecastViewPresentationInfo(name: hourly.name,
                                                  temperature: infoConverter.convertTemperatureToText(temp: hourly.temp,
                                                                                                      unit: currentInfo.unit),
                                                  icon: weatherIcon(for: hourly.weather.first?.main ?? ""))
    }

    func dailyViewPresentationInfo(index: Int) -> DailyForecastViewPresentationInfo {
        let daily = forecastInfo.daily[index]
        return DailyForecastViewPresentationInfo(name: daily.name,
                                                 icon: weatherIcon(for: daily.weather.first?.main ?? ""),
                                                 dailyForecast: daily.weather.first?.main ?? "",
                                                 tempMin: infoConverter.convertTemperatureToText(temp: daily.temp.min,
                                                                                                 unit: currentInfo.unit),
                                                 tempMax: infoConverter.convertTemperatureToText(temp: daily.temp.max,
                                                                                                 unit: currentInfo.unit))
    }

    func weatherIcon(for condition: String) -> String {
        switch condition {
        case "Clear":
            return "sun.max.fill"
        case "Clouds":
            return "cloud.fill"
        case "Rain":
            return "cloud.rain.fill"
        case "Snow":
            return "cloud.snow.fill"
        default:
            return "questionmark"
        }
    }
}

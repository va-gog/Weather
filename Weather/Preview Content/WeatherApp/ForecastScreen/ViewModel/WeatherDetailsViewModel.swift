//
//  WeatherDetailsViewModel.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Combine
import CoreLocation
import SwiftUI

final class WeatherDetailsViewModel: ObservableObject {
    @Published var currentInfo: WeatherCurrentInfo?
    @Published var forecastInfo = WeatherForecast(hourly: [], daily: [])
    @Published var fetchState: FetchState = .none
    
    private var selectedCity: City
    private var style: WeatherDetailsViewStyle
    private var networkManager: any NetworkManagerProtocol
    private var auth: AuthInterface
    private var infoConverter: WeatherInfoToPresentationInfoConverter
    private var addedWaetherInfo = PassthroughSubject<WeatherCurrentInfo, Never>()
    private var navigationManager: WeatherDetailsNavigationManagerInterface
    private var cancellables: [AnyCancellable] = []
        
    init(selectedCity: City,
         style: WeatherDetailsViewStyle,
         navigationManager: WeatherDetailsNavigationManagerInterface,
         networkManager: any NetworkManagerProtocol = NetworkManager(),
         auth: AuthInterface = AuthWrapper(),
         infoConverter: WeatherInfoToPresentationInfoConverter = WeatherInfoToPresentationInfoConverter(),
         currentInfo: WeatherCurrentInfo? = nil,
         addedWaetherInfo: PassthroughSubject<WeatherCurrentInfo, Never> = PassthroughSubject<WeatherCurrentInfo, Never>()){
        self.selectedCity = selectedCity
        self.style = style
        self.navigationManager = navigationManager
        self.networkManager = networkManager
        self.auth = auth
        self.infoConverter = infoConverter
        self.currentInfo = currentInfo
        self.addedWaetherInfo = addedWaetherInfo
    }
    
    func addFavoriteWeather() {
        guard let currentInfo else { return }
        navigationManager.addFavorite(weather: currentInfo)
    }
    
    func deleteButtonAction() {
        guard let currentInfo else { return }
        navigationManager.delete(weather: currentInfo.currentWeather)
        navigationManager.close()
    }
    
    func signedOut() throws {
        do {
            try auth.signOut()
            navigationManager.close()
        } catch {
            print("Signing out failed")
        }
    }
    
    func close() {
        navigationManager.close()
    }
    
    func presentationStyle() -> WeatherDetailsViewStyle {
        return style
    }
    
    func fetchWeatherCurrentInfo(unit: WeatherUnit = .celsius) {
        if currentInfo == nil {
            let currentWeatherURL = WeatherURLBuilder.URLForCurrent(latitude: selectedCity.lat,
                                                                    longitude: selectedCity.lon,
                                                                    unit: unit)
            networkManager.fetchAndDecode(from: currentWeatherURL, as: CurrentWeather.self)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    if case .failure(let error) = completion {
                        let fetchError = AppError.convertToFetchError(error: error)
                        self?.fetchState = .failed(fetchError)
                    }
                } receiveValue: { [weak self] current in
                    self?.currentInfo = WeatherCurrentInfo(currentWeather: current,
                                                           unit: unit,
                                                           isMyLocation: self?.currentInfo?.isMyLocation ?? false)
                }
                .store(in: &cancellables)
            
        }
        
    }
    
    func fetchForecastInfo() {
        let excludes = [OneCallApiExclude.current.rawValue, OneCallApiExclude.minutely.rawValue, OneCallApiExclude.alerts.rawValue]
        let forecastURL = WeatherURLBuilder.URLForForecast(latitude: selectedCity.lat,
                                                           longitude: selectedCity.lon,
                                                           exclude: excludes)
        networkManager.fetchAndDecode(from: forecastURL, as: WeatherForecast.self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    let fetchError = AppError.convertToFetchError(error: error)
                    self?.fetchState = .failed(fetchError)
                }
            } receiveValue: { [weak self] forecast in
                self?.forecastInfo = forecast
            }
            .store(in: &cancellables)
            
    }
    
    func topViewPresentationInfo(currentInfo: WeatherCurrentInfo?) -> TopViewInfo? {
        if let currentInfo {
            return TopViewInfo(name: infoConverter.currentLocationTitle(isMyLocation: currentInfo.isMyLocation,
                                                                        name: currentInfo.currentWeather.name),
                               city: currentInfo.currentWeather.name,
                               temperature: infoConverter.convertTemperatureToText(temp: currentInfo.currentWeather.main.temp,
                                                                                   unit: currentInfo.unit),
                               isMyLocation: currentInfo.isMyLocation,
                               icon: weatherIcon(for: currentInfo.currentWeather.weather.first?.main ?? ""))
        }
        return nil
    }
    
    func hourlyViewPresentationInfo(index: Int, currentInfo: WeatherCurrentInfo?) -> HourlyForecastViewInfo? {
        if let currentInfo {
            let hourly = forecastInfo.hourly[index]
            return HourlyForecastViewInfo(name: hourly.name,
                                                      temperature: infoConverter.convertTemperatureToText(temp: hourly.temp,
                                                                                                          unit: currentInfo.unit),
                                                      icon: weatherIcon(for: hourly.weather.first?.main ?? ""))
        }
        return nil
    }

    func dailyViewPresentationInfo(index: Int) -> DailyForecastViewInfo? {
        if let currentInfo {
            let daily = forecastInfo.daily[index]
            return DailyForecastViewInfo(name: daily.name,
                                         icon: weatherIcon(for: daily.weather.first?.main ?? ""),
                                         dailyForecast: daily.weather.first?.main ?? "",
                                         tempMin: LocalizedText.high + ":" + infoConverter.convertTemperatureToText(temp: daily.temp.min,
                                                                                                                    unit: currentInfo.unit),
                                         tempMax:LocalizedText.low + ":" + infoConverter.convertTemperatureToText(temp: daily.temp.max,
                                                                                                                  unit: currentInfo.unit))
        }
        return nil
    }

    func weatherIcon(for condition: String) -> String {
        switch condition {
        case "Clear":
            return AppIcons.clear
        case "Clouds":
            return  AppIcons.clouds
        case "Rain":
            return  AppIcons.rain
        case "Snow":
            return  AppIcons.snow
        default:
            return  AppIcons.otherWeather
        }
    }
}

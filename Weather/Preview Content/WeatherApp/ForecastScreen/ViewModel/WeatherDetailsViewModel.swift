//
//  WeatherDetailsViewModel.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Combine
import CoreLocation
import SwiftUI

final class WeatherDetailsState: ObservableObject, ReducerState {
    @Published var currentInfo: WeatherCurrentInfo?
    @Published var forecastInfo = WeatherForecast(hourly: [], daily: [])
    @Published var fetchState: FetchState = .none
}

enum WeatherDetailsViewIntent: Action {
    case deleteButtonAction
    case addFavoriteWeather
    case signedOut
    case close
    case fetchForecastInfo
    case fetchWeatherCurrentInfo
}

protocol ReducerState {}
protocol Action { }

protocol Reducer {
    associatedtype State: ReducerState
    
    var state: State { get }
    
    func send(_ action: Action)
}

final class WeatherDetailsViewModel: Reducer, ObservableObject {
    typealias State = WeatherDetailsState
    
    var state = WeatherDetailsState()
    
    @Dependency private var networkService: NetworkServiceProtocol
    @Dependency private var auth: AuthInterface
    @Dependency private var infoConverter: WeatherInfoToPresentationInfoConverterInterface
    
    private(set) var style: WeatherDetailsViewStyle
    private var selectedCity: City
    private weak var coordinator: CoordinatorInterface?
    private var cancelables: [AnyCancellable] = []
    private var unit = WeatherUnit.celsius
    
    init(selectedCity: City,
         style: WeatherDetailsViewStyle,
         coordinator: CoordinatorInterface,
         currentInfo: WeatherCurrentInfo?) {
        self.selectedCity = selectedCity
        self.style = style
        self.coordinator = coordinator
        self.state.currentInfo = currentInfo
        
        state.objectWillChange
            .receive(on: RunLoop.main)
            .sink(receiveValue: objectWillChange.send)
            .store(in: &cancelables)
    }
    
    func send(_ action: Action) {
        switch action as? WeatherDetailsViewIntent {
        case .addFavoriteWeather:
            addFavoriteWeather()
        case .deleteButtonAction:
            deleteButtonAction()
        case .signedOut:
            try? signedOut()
        case .close:
            close()
        case .fetchForecastInfo:
            fetchForecastInfo()
        case .fetchWeatherCurrentInfo:
            fetchWeatherCurrentInfo()
        default: break
        }
        
    }
    
    private func addFavoriteWeather() {
        Task { @MainActor in
            coordinator?.send(action: ForecastScreenAction.closeWhenAdded(state.currentInfo))
        }
    }
    
    private func deleteButtonAction() {
        Task { @MainActor in
            coordinator?.send(action: ForecastScreenAction.closeWhenDeleted(state.currentInfo))
        }
    }
    
    private func signedOut() throws {
        do {
            coordinator?.send(action: ForecastScreenAction.signOut)
            try auth.signOut()
        } catch {
            throw AppError.signOutFail
        }
    }
    
    private func close() {
        Task { @MainActor in
            coordinator?.send(action: ForecastScreenAction.cancel)
        }
    }
    
    func bottomToolbarTabs() -> [TabItem] {
        let deleteDisabled = (state.currentInfo?.isMyLocation ?? false) || style == .overlay
        let disabledButtons = deleteDisabled ? [ForecastScreenToolbarTabType.remove] : []
        return TabItemFactory().createBottomToolbarItems(enabledTypes: disabledButtons)
    }
    
    private func fetchWeatherCurrentInfo() {
        if state.currentInfo == nil {
            let request = RequestFactory.currentWeatherRequest(coordinates: Coordinates(lon: selectedCity.lon,
                                                                                        lat: selectedCity.lat))
            networkService.requestData(request, as: CurrentWeather.self)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    if case .failure(let error) = completion {
                        let fetchError = AppError.appError(error: error)
                        self?.state.fetchState = .failed(fetchError)
                    }
                } receiveValue: { [weak self] current in
                    guard let self else { return }
                    self.state.fetchState = .succeed
                    self.state.currentInfo = WeatherCurrentInfo(currentWeather: current,
                                                                 unit: self.unit,
                                                                 isMyLocation: self.state.currentInfo?.isMyLocation ?? false)
                }
                .store(in: &cancelables)
            
        }
        
    }
    
    private func fetchForecastInfo() {
        let request = RequestFactory.forecastWeatherRequest(coordinates: Coordinates(lon: selectedCity.lon,
                                                                                     lat: selectedCity.lat))
        networkService.requestData(request, as: WeatherForecast.self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    let fetchError = AppError.appError(error: error)
                    self?.state.fetchState = .failed(fetchError)
                }
            } receiveValue: { [weak self] forecast in
                self?.state.forecastInfo = forecast
            }
            .store(in: &cancelables)
        
    }
    
    func topViewPresentationInfo(currentInfo: WeatherCurrentInfo?) -> TopViewInfo? {
        if let currentInfo {
            return TopViewInfo(name: infoConverter.currentLocationTitle(isMyLocation: currentInfo.isMyLocation,
                                                                                     name: currentInfo.currentWeather.name),
                               city: currentInfo.currentWeather.name,
                               temperature: infoConverter.convertTemperatureToText(temp: currentInfo.currentWeather.main.temp,
                                                                                                unit: currentInfo.unit),
                               isMyLocation: currentInfo.isMyLocation,
                               icon: infoConverter.weatherIcon(for: currentInfo.currentWeather.weather.first?.main))
        }
        return nil
    }
    
    func hourlyViewPresentationInfo(index: Int, unit: WeatherUnit) -> HourlyForecastViewInfo? {
        if state.forecastInfo.hourly.indices.contains(index) {
            let hourly = state.forecastInfo.hourly[index]
            return HourlyForecastViewInfo(name: hourly.name,
                                          temperature: infoConverter.convertTemperatureToText(temp: hourly.temp,
                                                                                                           unit: unit),
                                          icon: infoConverter.weatherIcon(for: hourly.weather.first?.main))
        }
        return nil
    }
    
    func dailyViewPresentationInfo(index: Int, unit: WeatherUnit) -> DailyForecastViewInfo? {
        if state.forecastInfo.daily.indices.contains(index) {
            let daily = state.forecastInfo.daily[index]
            return DailyForecastViewInfo(name: daily.name,
                                         icon: infoConverter.weatherIcon(for: daily.weather.first?.main),
                                         dailyForecast: daily.weather.first?.main ?? "",
                                         tempMin: LocalizedText.high + ":" + infoConverter.convertTemperatureToText(temp: daily.temp.min,
                                                                                                                                 unit: unit),
                                         tempMax:LocalizedText.low + ":" + infoConverter.convertTemperatureToText(temp: daily.temp.max,
                                                                                                                               unit: unit))
        }
        return nil
    }
}

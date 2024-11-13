//
//  Coordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

import SwiftUI

@MainActor
final class Coordinator: ObservableObject, @preconcurrency CoordinatorInterface {
    @Published var path: NavigationPath = NavigationPath()
    
    var dependenciesManager: DependencyManagerInterface
    
    private var mainScreenViewModel: MainScreenViewModel?
    private var forecastScreenViewModel: WeatherDetailsViewModel?
    
    init(dependenciesManager: DependencyManagerInterface) {
        self.dependenciesManager = dependenciesManager
    }
    
    func push(page: AppPages) {
        Task {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            path.append(page)
        }
    }
    
    func pushMainScreen() {
        mainScreenViewModel = MainScreenViewModel(coordinator: self)
        push(page: .main)
    }
    
    func pushForecastView(selectedCity: City, style: WeatherDetailsViewStyle, currentInfo: WeatherCurrentInfo?) {
        forecastScreenViewModel = WeatherDetailsViewModel(selectedCity: selectedCity,
                                                          style: style,
                                                          coordinator: self,
                                                          currentInfo: currentInfo)
            push(page: .forecast)
    }
    
    func pop(_ page: PopAction) {
        guard !path.isEmpty else { return }
        switch page {
        case .last:
            path.removeLast()
        case .forecastClose:
            forecastScreenViewModel = nil
            path.removeLast()
        case .authentication:
            path.removeLast()
        case .signOut:
            pop(.forecastClose)
            pop(.mainClose)
        default:
            path.removeLast()
        }
    }
    
    func popForecastViewWhenDeleted(info: WeatherCurrentInfo?) {
        guard let info else { return }
        mainScreenViewModel?.deleteButtonPressed(info: info.currentWeather)
        pop(.delete)
    }
    
    func popForecastViewWhenAdded(info: WeatherCurrentInfo?) {
        guard let info else { return }
        mainScreenViewModel?.addButtonPressed(info: info)
        pop(.add)
    }
        
    func build(page: AppPages) -> any View {
        switch page {
        case .locationAccess:
            return LocationPermitionView()
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
        case .main:
            guard let mainScreenViewModel else {
                assertionFailure("Main screen should have ViewModel")
                return AnyView(EmptyView())
            }
            return MainView()
                .environmentObject(mainScreenViewModel)
                .navigationBarBackButtonHidden(true)
                .navigationTitle(LocalizedText.weather)
            
        case .authentication:
            return  AuthenticationView()
                .environmentObject(AuthenticationViewModel(coordinator: self))
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
            
        case .forecast:
            guard let forecastScreenViewModel else {
                assertionFailure("Forecast screen should have ViewModel")
                return EmptyView()
            }
            return WeatherDetailsView(presentationInfo: WeatherDetailsViewPresentationInfo())
                .environmentObject(forecastScreenViewModel)
        }
    }
}

//
//  Coordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

import SwiftUI

final class Coordinator: ObservableObject, @preconcurrency CoordinatorInterface {
    @Published var path: NavigationPath = NavigationPath()
    var dependenciesManager: DependencyManagerInterface
    
    @Published private var mainScreenViewModel: MainScreenViewModel?
    @Published private var forecastScreenViewModel: WeatherDetailsViewModel?
    
    init(dependenciesManager: DependencyManagerInterface,
         mainScreenViewModel: MainScreenViewModel? = nil) {
        self.dependenciesManager = dependenciesManager
        self.mainScreenViewModel = MainScreenViewModel(coordinator: self)
    }
    
    @MainActor
    func push(page: AppPages) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            DispatchQueue.main.async {
                self.path.append(page)
            }
        }
    }
    
    @MainActor
    func pushForecastView(selectedCity: City, style: WeatherDetailsViewStyle, currentInfo: WeatherCurrentInfo?) {
        forecastScreenViewModel = WeatherDetailsViewModel(selectedCity: selectedCity,
                                                          style: style,
                                                          coordinator: self,
                                                          currentInfo: currentInfo)
        Task { @MainActor in
            push(page: .forecast)
        }
    }
    
    @MainActor
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
    
    @MainActor
    func popForecastViewWhenDeleted(info: WeatherCurrentInfo?) {
        guard let info else { return }
        mainScreenViewModel?.deleteButtonPressed(info: info.currentWeather)
        pop(.delete)
    }
    
    @MainActor
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

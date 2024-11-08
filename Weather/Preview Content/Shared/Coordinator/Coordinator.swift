//
//  Coordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

import SwiftUI

protocol CoordinatorInterface {
    var dependenciesManager: DependencyManagerInterface { get }
    
    func pushForecastView(selectedCity: City, style: WeatherDetailsViewStyle, currentInfo: WeatherCurrentInfo?)
    func popForecastViewWhenDeleted(info: WeatherCurrentInfo)
    func popForecastViewWhenAdded(info: WeatherCurrentInfo)
    func push(page: AppPages)
    func pop(_ page: PopAction)
}

final class Coordinator: ObservableObject, @preconcurrency CoordinatorInterface {
    @Published var path: NavigationPath = NavigationPath()
    var dependenciesManager: DependencyManagerInterface = DependencyManager()
    
    @Published private var mainScreenViewModel: MainScreenViewModel?
    @Published private var forecastScreenViewModel: WeatherDetailsViewModel?
    
    init(mainScreenViewModel: MainScreenViewModel? = nil, forecastScreenViewModel: WeatherDetailsViewModel? = nil) {
        self.mainScreenViewModel = MainScreenViewModel(coordinator: self,
                                                       dependencyManager: self.dependenciesManager)
    }
    
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
    func popForecastViewWhenDeleted(info: WeatherCurrentInfo) {
        mainScreenViewModel?.deleteButtonPressed(info: info.currentWeather)
        pop(.delete)
    }
    
    @MainActor
    func popForecastViewWhenAdded(info: WeatherCurrentInfo) {
        mainScreenViewModel?.addButtonPressed(info: info)
        pop(.add)
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
    func pop(_ page: PopAction) {
        guard !path.isEmpty else { return }
        switch page {
        case .forecastClose:
            forecastScreenViewModel = nil
            path.removeLast()
        case .authenticated:
            path.removeLast()
        case .signOut:
            pop(.forecastClose)
            pop(.mainClose)
        default:
            path.removeLast()
        }
    }
        
    func build(page: AppPages) -> some View {
        switch page {
        case .locationAccess:
            return AnyView(
                LocationPermitionView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
            )
            
        case .main:
                guard let mainScreenViewModel else {
                    assertionFailure("Main screen should have ViewModel")
                    return AnyView(EmptyView())
                }
            return AnyView(
                MainView()
                    .environmentObject(mainScreenViewModel)
                    .navigationBarBackButtonHidden(true)
                    .navigationTitle(LocalizedText.weather)
            )
            
        case .login:
            return AnyView(
                AuthenticationView()
                    .environmentObject(AuthenticationViewModel(coordinator: self,
                                                               auth: AuthWrapper()))
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
            )
            
        case .forecast:
            guard let forecastScreenViewModel else {
                assertionFailure("Forecast screen should have ViewModel")
                return AnyView(EmptyView())
            }
            return AnyView(
                WeatherDetailsView(presentationInfo: WeatherDetailsViewPresentationInfo())
                                                       .environmentObject(forecastScreenViewModel)
            )
            
        }
    }
}

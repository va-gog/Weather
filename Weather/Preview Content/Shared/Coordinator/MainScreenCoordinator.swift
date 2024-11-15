//
//  MainScreenCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 15.11.24.
//

import SwiftUI

final class MainScreenCoordinator: MainScreenCoordinatorInterface {
    var type: AppPages = .main
    var parent: (CoordinatorInterface)?
    var childs: [CoordinatorInterface] = []
    var dependenciesManager: DependencyManagerInterface
    
    var mainScreenViewModel: MainScreenViewModel?
    
    init(parent: CoordinatorInterface?,
         dependenciesManager: DependencyManagerInterface,
         mainScreenViewModel: MainScreenViewModel? = nil) {
        self.parent = parent
        self.mainScreenViewModel = mainScreenViewModel
        self.dependenciesManager = dependenciesManager
    }

    func push(page: AppPages) {
        parent?.push(page: page)
    }
    
    func pushForecastView(selectedCity: City, style: WeatherDetailsViewStyle, currentInfo: WeatherCurrentInfo?) {
        let coordinator = ForecastScreenCoordinator(parent: self,
                                                    dependenciesManager: dependenciesManager)
        let viewModel = WeatherDetailsViewModel(selectedCity: selectedCity,
                                                style: style,
                                                coordinator: coordinator,
                                                currentInfo: currentInfo)
        coordinator.forecastScreenViewModel = viewModel
        childs.append(coordinator)
        
        push(page: .forecast)
    }

    func pop(pages: [AppPages]) {
        for page in pages {
            if let index = childs.firstIndex(where: {$0.type == page } ) {
                childs.remove(at: index)
            }
        }
        parent?.pop(pages: pages)
    }
    
    func popForecastViewWhenDeleted(info: WeatherCurrentInfo?) {
        guard let info else { return }
        mainScreenViewModel?.deleteButtonPressed(info: info.currentWeather)
    }
    
    func popForecastViewWhenAdded(info: WeatherCurrentInfo?) {
        guard let info else { return }
        mainScreenViewModel?.addButtonPressed(info: info)
    }

    func build(screen: AppPages) -> AnyView? {
        if screen == type {
            guard let mainScreenViewModel else { return nil }
            return AnyView(
                MainView()
                    .environmentObject(mainScreenViewModel)
                    .navigationBarBackButtonHidden(true)
                    .navigationTitle(LocalizedText.weather)
            )
        } else {
            for child in childs {
                if let view = child.build(screen: screen) {
                    return view
                }
            }
            return nil
            
        }
    }
}

//
//  ForecastScreenCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 15.11.24.
//

import SwiftUI

final class ForecastScreenCoordinator: ForecastScreenCoordinatorInterface {
    var type: AppPages = .forecast
    var parent: (CoordinatorInterface)?
    var childs: [CoordinatorInterface] = []
    var dependenciesManager: DependencyManagerInterface
    
    var forecastScreenViewModel: WeatherDetailsViewModel?
    
    init(parent: CoordinatorInterface?,
         dependenciesManager: DependencyManagerInterface,
         forecastScreenViewModel: WeatherDetailsViewModel? = nil) {
        self.parent = parent
        self.forecastScreenViewModel = forecastScreenViewModel
        self.dependenciesManager = dependenciesManager
    }

    func push(page: AppPages) {}
    
    func pop(pages: [AppPages]) {
        parent?.pop(pages: pages)
    }
    
    func cancel() {
        pop(pages: [.forecast])
    }
    
    func signOut() {
        pop(pages: [.forecast, .main])
    }
    
    func closeWhenDeleted(info: WeatherCurrentInfo?) {
        guard let parent = parent as? MainScreenCoordinator else { return }
        parent.popForecastViewWhenDeleted(info: info)
        pop(pages: [type])
    }
    
    func closeWhenAdded(info: WeatherCurrentInfo?) {
        guard let parent = parent as? MainScreenCoordinator else { return }
        parent.popForecastViewWhenAdded(info: info)
        pop(pages: [type])
    }
    
    func build(screen: AppPages) -> AnyView? {
        if screen == type {
            guard let forecastScreenViewModel else { return nil }

            return AnyView(
                WeatherDetailsView()
                .environmentObject(forecastScreenViewModel)
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

//
//  ForecastScreenCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 15.11.24.
//

import SwiftUI

enum ForecastScreenAction: Action {
    case closeWhenDeleted(WeatherCurrentInfo?)
    case closeWhenAdded(WeatherCurrentInfo?)
    case cancel
    case signOut
}

final class ForecastScreenCoordinator: CoordinatorInterface {
    var type: any AppScreen = WeatherAppScreen.forecast
    var parent: (any CoordinatorInterface)?
    var childs: [any CoordinatorInterface] = []
    var forecastScreenViewModel: WeatherDetailsViewModel?
    
    init(parent: (any CoordinatorInterface)?,
         forecastScreenViewModel: WeatherDetailsViewModel? = nil) {
        self.parent = parent
        self.forecastScreenViewModel = forecastScreenViewModel
    }
        
    func send(_ action: Action) {
        switch action as? ForecastScreenAction {
        case .cancel:
            cancel()
        case .signOut:
            signOut()
        case .closeWhenDeleted(let info):
            closeWhenDeleted(info: info)
        case .closeWhenAdded(let info):
            closeWhenAdded(info: info)
        default:
            break
        }
    }
    
    func pop(_ screens: [any AppScreen]) {
        parent?.pop(screens)
    }
    
    func cancel() {
        pop([WeatherAppScreen.forecast])
    }
    
    private func signOut() {
        pop([WeatherAppScreen.forecast,
             WeatherAppScreen.main])
    }
    
    private func closeWhenDeleted(info: WeatherCurrentInfo?) {
        guard let parent = parent as? MainScreenCoordinator else { return }
        parent.send(MainScreenAction.Delegate.popForecastViewWhenDeleted(info))
        pop([type])
    }
    
    private func closeWhenAdded(info: WeatherCurrentInfo?) {
        guard let parent = parent as? MainScreenCoordinator else { return }
        parent.send(MainScreenAction.Delegate.popForecastViewWhenAdded(info))
        pop([type])
    }
    
    func build(screen: any AppScreen) -> AnyView? {
        guard let screen = screen as? WeatherAppScreen, let type = type as? WeatherAppScreen else { return nil }
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

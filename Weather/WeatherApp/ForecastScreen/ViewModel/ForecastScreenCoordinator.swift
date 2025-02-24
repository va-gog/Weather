//
//  ForecastScreenCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 15.11.24.
//

import SwiftUI

final class ForecastScreenCoordinator: CoordinatorInterface {
    var type: any AppScreen = WeatherAppScreen.forecast
    var parent: (any CoordinatorInterface)?
    var childs: [any CoordinatorInterface] = []
    var reducer: (any Reducer)?
    
    init(parent: (any CoordinatorInterface)?,
         reducer: (any Reducer)? = nil) {
        self.parent = parent
        self.reducer = reducer
    }
        
    func send(action: Action) {
        switch action as? ForecastViewAction.Delegate {
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
    
    func build(screen: any AppScreen) -> (any View)? {
        guard let screen = screen as? WeatherAppScreen, let type = type as? WeatherAppScreen else { return nil }
        if screen == type {
            guard let reducer else { return nil }
            
            return AnyView(
                WeatherDetailsView()
                    .environmentObject(reducer)
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
    
    private func cancel() {
        pop([WeatherAppScreen.forecast])
    }
    
    private func signOut() {
        pop([WeatherAppScreen.forecast,
             WeatherAppScreen.main])
    }
    
    private func closeWhenDeleted(info: WeatherCurrentInfo?) {
        guard let parent = parent as? MainScreenCoordinator else { return }
        parent.send(action: MainScreenAction.Delegate.popForecastViewWhenDeleted(info))
        pop([type])
    }
    
    private func closeWhenAdded(info: WeatherCurrentInfo?) {
        guard let parent = parent as? MainScreenCoordinator else { return }
        parent.send(action: MainScreenAction.Delegate.popForecastViewWhenAdded(info))
        pop([type])
    }
}

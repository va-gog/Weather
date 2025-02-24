//
//  MainScreenCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 15.11.24.
//

import SwiftUI

final class MainScreenCoordinator: CoordinatorInterface {
    var reducer: (any Reducer)?
    
    var type: any AppScreen = WeatherAppScreen.main
    var parent: (any CoordinatorInterface)?
    var childs: [any CoordinatorInterface] = []
        
    init(parent: (any CoordinatorInterface)? = nil,
         reducer: (any Reducer)? = nil) {
        self.parent = parent
        self.reducer = reducer
    }

    func push(_ screen: any AppScreen) {
        // check if push should be made by curret view or parent
        parent?.push(screen)
    }
    
    func pop(_ screens: [any AppScreen]) {
        for screen in screens {
            if let index = childs.firstIndex(where: { ($0.type as? WeatherAppScreen) == (screen as? WeatherAppScreen) }) {
                childs.remove(at: index)
            }
        }
        parent?.pop(screens)
    }

    func build(screen: any AppScreen) -> (any View)? {
        guard let screen = screen as? WeatherAppScreen, let type = type as? WeatherAppScreen else { return nil }
        if screen == type {
            guard let reducer = reducer as? MainScreenViewModel else { return nil }
            return AnyView(
                MainView()
                    .environmentObject(reducer)
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
    
    func send(action: Action) {
        switch action as? MainScreenAction.Delegate {
        case .popForecastViewWhenAdded(let info):
            popForecastViewWhenAdded(info: info)
        case .popForecastViewWhenDeleted(let info):
            popForecastViewWhenDeleted(info: info)
        case .pushForecastView(let city, let style, let info):
            pushForecastView(selectedCity: city, style: style, currentInfo: info)
        default:
            break
        }
    }
    
    private func popForecastViewWhenDeleted(info: WeatherCurrentInfo?) {
        guard let info else { return }
        reducer?.send(MainScreenAction.deleteButtonPressed(info.currentWeather))
    }
    
    private func popForecastViewWhenAdded(info: WeatherCurrentInfo?) {
        guard let info else { return }
        reducer?.send(MainScreenAction.addButtonPressed(info))
    }
    
    private func pushForecastView(selectedCity: City, style: WeatherDetailsViewStyle, currentInfo: WeatherCurrentInfo?) {
        let coordinator = ForecastScreenCoordinator(parent: self)
        let viewModel = ForecastViewModel(selectedCity: selectedCity,
                                                style: style,
                                                coordinator: coordinator,
                                                currentInfo: currentInfo)
        coordinator.reducer = viewModel
        childs.append(coordinator)
        
        push(WeatherAppScreen.forecast)
    }

}

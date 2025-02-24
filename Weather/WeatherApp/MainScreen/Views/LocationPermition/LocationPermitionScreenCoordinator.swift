//
//  LocationPermitionScreenCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 15.11.24.
//

import SwiftUI

final class LocationPermitionScreenCoordinator: CoordinatorInterface {
    var reducer: (any Reducer)?
    var type: any AppScreen =  WeatherAppScreen.locationAccess
    var parent: (any CoordinatorInterface)?
    var childs: [any CoordinatorInterface] = []

    func build(screen: any AppScreen) -> (any View)? {
            LocationPermitionView()
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
}

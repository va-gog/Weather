//
//  LocationPermitionScreenCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 15.11.24.
//

import SwiftUI

final class LocationPermitionScreenCoordinator: CoordinatorInterface {
    var type: any AppScreen = WeatherAppScreen.locationAccess
    var parent: (CoordinatorInterface)?
    var childs: [CoordinatorInterface] = []

    func build(screen: any AppScreen) -> AnyView? {
        AnyView(
            LocationPermitionView()
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        )
    }
}

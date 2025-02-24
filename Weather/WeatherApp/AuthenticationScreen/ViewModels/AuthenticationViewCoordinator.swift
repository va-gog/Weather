//
//  AuthenticationViewCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 15.11.24.
//

import SwiftUI

final class AuthenticationViewCoordinator: CoordinatorInterface {
    var reducer: (any Reducer)?
    var type: any AppScreen = WeatherAppScreen.authentication
    var parent: (any CoordinatorInterface)?
    var childs: [any CoordinatorInterface] = []
        
    func build(screen: any AppScreen) -> (any View)?  {
        AuthenticationView()
            .environmentObject(AuthenticationViewModel())
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
}

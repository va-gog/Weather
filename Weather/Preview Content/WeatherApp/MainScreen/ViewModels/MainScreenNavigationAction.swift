//
//  MainScreenNavigationAction.swift
//  Weather
//
//  Created by Gohar Vardanyan on 05.11.24.
//

import SwiftUI
enum PopAction {
    case forecastClose
    case signOut
    case delete
    case add
    case authenticated
    case mainClose
}

enum AppPages: Hashable {
    case main
    case login
    case locationAccess
    case forecast
}



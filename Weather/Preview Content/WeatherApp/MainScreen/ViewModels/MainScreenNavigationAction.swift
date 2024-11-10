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
    case authentication
    case mainClose
    case last
}

enum AppPages: Hashable {
    case main
    case authentication
    case locationAccess
    case forecast
}



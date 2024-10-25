//
//  WeatherApp.swift
//  Weather
//
//  Created by Gohar Vardanyan on 23.10.24.
//

import SwiftUI

@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 0) {
                MainView(viewModel: MainScreenViewModel())
            }
        }
    }
}

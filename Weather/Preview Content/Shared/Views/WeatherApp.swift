//
//  WeatherApp.swift
//  Weather
//
//  Created by Gohar Vardanyan on 23.10.24.
//

import SwiftUI

@main
struct WeatherApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var coordinatorViewModel = AppLaunchViewModel(coordinator: Coordinator())
    
    private var viewModel = WeatherAppViewModel()

    var body: some Scene {
        WindowGroup {
            AppLaunchView()
                .environmentObject(coordinatorViewModel)
                .environmentObject(coordinatorViewModel.coordinator)
        }
        .onChange(of: scenePhase) { _, newValue in
            viewModel.setupBackgroundRequest(phase: newValue)
        }
        .backgroundTask(.appRefresh(WeatherAppViewModel.appRefreshIdentifier)) {
            await viewModel.startUserNotif()
        }
    }

}

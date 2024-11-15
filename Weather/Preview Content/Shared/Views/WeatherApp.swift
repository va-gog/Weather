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
    
    private var dependenciesManager = DependencyManager()
    private var viewModel: WeatherAppViewModel
    @ObservedObject private var coordinatorViewModel: AppLaunchViewModel
    
    init() {
        self.viewModel = WeatherAppViewModel(dependencyManager: dependenciesManager)
        self.coordinatorViewModel = AppLaunchViewModel(coordinator: AppLaunchScreenCoordinator(dependenciesManager: dependenciesManager))
    }
    
    var body: some Scene {
        WindowGroup {
            AppLaunchView(coordinator: coordinatorViewModel.coordinator as! AppLaunchScreenCoordinator)
                .environmentObject(coordinatorViewModel)
                .onChange(of: scenePhase) { _,  phase in
                    if phase == .background {
                        viewModel.submitBackgroundTasks()
                    }
                }
        }
    }
}

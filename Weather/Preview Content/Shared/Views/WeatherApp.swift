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
    
    private var viewModel: WeatherAppViewModel
    
    init() {
        self.viewModel = WeatherAppViewModel(dependencyManager: DependencyManager())
    }
    
    var body: some Scene {
        WindowGroup {
            AppLaunchView(coordinator: viewModel.coordinatorViewModel.coordinator as! Coordinator)
                .environmentObject(viewModel.coordinatorViewModel)
                .onChange(of: scenePhase) { _,  phase in
                    if phase == .background {
                        viewModel.submitBackgroundTasks()
                    }
                }
        }
    }
}

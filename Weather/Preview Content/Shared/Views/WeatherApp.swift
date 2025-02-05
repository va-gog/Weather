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
    @ObservedObject private var appLaunchViewModel: AppLaunchViewModel
    
    init() {
        self.appLaunchViewModel = AppLaunchViewModel(coordinator: AppLaunchScreenCoordinator())
        self.viewModel = WeatherAppViewModel()
    }
    
    var body: some Scene {
        WindowGroup {
            AppLaunchView(coordinator: appLaunchViewModel.coordinator as! AppLaunchScreenCoordinator)
                .environmentObject(appLaunchViewModel)
                .onChange(of: scenePhase) { _,  phase in
                    if phase == .background {
                        viewModel.submitBackgroundTasks()
                    }
                }
        }
    }
}

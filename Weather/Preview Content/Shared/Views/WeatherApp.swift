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
    @StateObject var mainViewModel = MainScreenViewModel()
    private var viewModel = WeatherAppViewModel()
    
    @ObservedObject var coordinator = AuthenticationScreenCoordinator()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                        switch coordinator.state {
                        case .unauthenticated, .authenticating:
                            AuthenticationView()
                                .environmentObject(coordinator.viewModel)
                                .onAppear() {
                                    coordinator.viewModel.registerAuthStateHandler()
                                }
                        case .authenticated:
                            VStack {
                                MainView()
                                    .environmentObject(MainScreemCoordinator(viewModel: mainViewModel,
                                                                             parent: coordinator))
                            }
                        }
            }
            .onChange(of: scenePhase) { _, newValue in
                viewModel.setupBackgroundRequest(phase: newValue)
            }
        }
        .backgroundTask(.appRefresh(WeatherAppViewModel.appRefreshIdentifier)) {
            await viewModel.startUserNotif()
        }
    }

}

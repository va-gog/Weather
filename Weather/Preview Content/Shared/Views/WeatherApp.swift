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
    @StateObject var authenticationViewModel = AuthenticationViewModel(auth: AuthWrapper())
    
    private var viewModel = WeatherAppViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                switch authenticationViewModel.authenticationState {
                        case .unauthenticated, .authenticating:
                            AuthenticationView()
                                .environmentObject(authenticationViewModel)
                                .onAppear() {
                                    authenticationViewModel.registerAuthStateHandler()
                                }
                        case .authenticated:
                            VStack {
                                MainView()
                                    .environmentObject(MainScreenViewModel(navigationManager: MainScreenNavigationManager(parent: authenticationViewModel.coordinator)))
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

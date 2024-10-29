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
    
    private var viewModel = WeatherAppViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                AuthenticatedView {
                    Text(NSLocalizedString("You need to be logged in to use this app.",
                                           comment: ""))
                } content: {
                    MainView(viewModel: MainScreenViewModel(),
                             presentationInfo: MainViewPresentationInfo())
                }
                .onChange(of: scenePhase) { _, newValue in
                    viewModel.setupBackgroundRequest(phase: newValue)
                }
            }
        }
        .backgroundTask(.appRefresh(WeatherAppViewModel.appRefreshIdentifier)) {
            await viewModel.startUserNotif()
        }
    }

}

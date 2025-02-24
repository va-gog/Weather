//
//  AppLaunchView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

import SwiftUI

struct AppLaunchView: View {
    @EnvironmentObject var viewModel: AppLaunchViewModel
    @ObservedObject var coordinator: AppLaunchScreenCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            EmptyView()
                .navigationDestination(for: WeatherAppScreen.self) { page in
                    buildView(coordinator.build(screen: page) ?? EmptyView())
                }
        }
        .onAppear {
            viewModel.registerAuthStateHandler()
        }
    }
    
    @ViewBuilder
    private func buildView(_ view: any View) -> some View {
        AnyView(view)
    }

}

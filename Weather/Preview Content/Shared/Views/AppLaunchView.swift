//
//  AppLaunchView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

import SwiftUI

struct AppLaunchView: View {
    @EnvironmentObject var viewModel: AppLaunchViewModel
    @ObservedObject var coordinator: Coordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            //TODO: This should be replaced with LaunchScreen
            EmptyView()
                .navigationDestination(for: AppPages.self) { page in
                    AnyView(coordinator.build(page: page))
                }
        }
        .onAppear() {
            viewModel.registerAuthStateHandler()
        }
    }
}

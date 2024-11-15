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
                .navigationDestination(for: AppPages.self) { page in
                   coordinator.build(screen: page) ?? AnyView(EmptyView())
                }
        }
        .onAppear() {
            viewModel.registerAuthStateHandler()
        }
    }
}

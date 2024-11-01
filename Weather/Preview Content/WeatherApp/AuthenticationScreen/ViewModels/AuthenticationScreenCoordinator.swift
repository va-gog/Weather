//
//  AuthenticationScreenCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 01.11.24.
//

import SwiftUI

@MainActor
final class AuthenticationScreenCoordinator: ObservableObject {
    @ObservedObject var viewModel = AuthenticationViewModel(auth: AuthWrapper())
    @Published var state: AuthenticationState = .unauthenticated
    
    init() {
        viewModel.$authenticationState
            .receive(on: RunLoop.main)
            .assign(to: &$state)
    }
    
    func changeState(_ newState: AuthenticationState) {
        viewModel.authenticationState = newState
    }
    
}

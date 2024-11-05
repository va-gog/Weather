//
//  AuthenticationScreenNavigationManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 01.11.24.
//

import SwiftUI

final class AuthenticationScreenNavigationManager: ObservableObject, AuthenticationScreenNavigationManagerInterface {
    @Published var state: AuthenticationState = .unauthenticated
    
    func changeState(_ newState: AuthenticationState) {
        Task { @MainActor in
            state = newState
        }
    }
    
}

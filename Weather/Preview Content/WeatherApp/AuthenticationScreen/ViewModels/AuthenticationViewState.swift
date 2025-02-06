//
//  AuthenticationViewState.swift
//  Weather
//
//  Created by Gohar Vardanyan on 06.02.25.
//

import SwiftUI
import GoogleSignInSwift
import FirebaseAuth

final class AuthenticationViewState: ObservableObject, ReducerState {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var flow: AuthenticationFlow = .login
    @Published var isValid  = false
    @Published var errorMessage = ""
    @Published var user: User?
    @Published var displayName: String = ""
    @Published var authenticationState: AuthenticationState = .none
    
    init() {
        
        $flow
            .combineLatest($email, $password, $confirmPassword)
            .map { flow, email, password, confirmPassword in
                flow == .login
                ? !(email.isEmpty || password.isEmpty)
                : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
            }
            .assign(to: &$isValid)
    }
}

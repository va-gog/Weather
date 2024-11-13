//
//  AuthenticationViewModel.swift
//  Weather
//
//  Created by Gohar Vardanyan on 26.10.24.
//

import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var flow: AuthenticationFlow = .login
    @Published var isValid  = false
    @Published var errorMessage = ""
    @Published var user: User?
    @Published var displayName: String = ""
    @Published var authenticationState: AuthenticationState = .none
    
    private var coordinator: CoordinatorInterface
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    private var dependencies: AuthenticationScreenDependenciesInterface
    
    init(coordinator: CoordinatorInterface) {
        self.coordinator = coordinator
        self.dependencies = coordinator.dependenciesManager.createAuthenticationScreenDependencies()
        
        $flow
            .combineLatest($email, $password, $confirmPassword)
            .map { flow, email, password, confirmPassword in
                flow == .login
                ? !(email.isEmpty || password.isEmpty)
                : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
            }
            .assign(to: &$isValid)
    }
    
    
    func autofillPassword() {
        do {
            password = try dependencies.keychain.retrieveItem(key: email,
                                                              secClass: kSecClassGenericPassword)
        } catch {
            password = ""
        }
    }
    
    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        errorMessage = ""
    }
    
    func reset() {
        flow = .login
        email = ""
        password = ""
        confirmPassword = ""
    }
    
    func signAction() async -> Bool {
        Task { @MainActor in
            authenticationState = .authenticating
        }
        return switch flow {
        case .login:
            await signInWithEmailPassword()
        case .signUp:
            await signUpWithEmailPassword()
        }
    }
    
    private func signInWithEmailPassword() async -> Bool {
        do {
            _ = try await dependencies.auth.signIn(withEmail: self.email,
                                                   password: self.password)
            try? self.dependencies.keychain.saveItem(data: self.password.data(using: .utf8),
                                                     key: self.email,
                                                     secClass: kSecClassGenericPassword)
            return true
        }
        catch  {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    private func signUpWithEmailPassword() async -> Bool {
        do  {
            _ = try await dependencies.auth.createUser(withEmail: email, password: password)
            return true
        }
        catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}


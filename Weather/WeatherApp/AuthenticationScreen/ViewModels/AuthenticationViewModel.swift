//
//  AuthenticationViewModel.swift
//  Weather
//
//  Created by Gohar Vardanyan on 26.10.24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignInSwift
import Combine

final class AuthenticationViewModel: ObservableObject, Reducer {
    typealias State = AuthenticationViewState
    
    var state = AuthenticationViewState()
    var cancelables: [AnyCancellable] = []
    
    @Dependency private var keychain: KeychainManagerInterface
    @Dependency private var auth: AuthInterface
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    init(keychain: KeychainManagerInterface? = nil, auth: AuthInterface? = nil) {
        if let keychain, let auth {
            self.keychain = keychain
            self.auth = auth
        }
        observableReducer()
    }
    
    func send(_ action: any Action) {
        switch action as? AuthenticationViewAction {
        case .autofillPassword:
            autofillPassword()
        case .switchFlow:
            switchFlow()
        case .reset:
            reset()
        case .signAction:
            Task {
                await signAction()
            }
        case .signInWithEmailPassword:
            Task {
                await signInWithEmailPassword()
            }
        case .signUpWithEmailPassword:
            Task {
            await signUpWithEmailPassword()
            }
        default:
            break
        }
    }
    
    private func autofillPassword() {
        do {
            state.password = try keychain.retrieveItem(key: state.email,
                                                              secClass: kSecClassGenericPassword)
        } catch {
            state.password = ""
        }
    }
    
    private func switchFlow() {
        state.flow = state.flow == .login ? .signUp : .login
        state.errorMessage = ""
    }
    
    private func reset() {
        state.flow = .login
        state.email = ""
        state.password = ""
        state.confirmPassword = ""
    }
    
    @MainActor
    private func signAction() async  {
        Task { @MainActor in
            state.authenticationState = .authenticating
        }
        return switch state.flow {
        case .login:
            await signInWithEmailPassword()
        case .signUp:
            await signUpWithEmailPassword()
        }
    }
    
    @MainActor
    private func signInWithEmailPassword() async {
        do {
            _ = try await auth.signIn(withEmail: state.email,
                                      password: state.password)
            try? keychain.saveItem(data: state.password.data(using: .utf8),
                                   key: state.email,
                                                     secClass: kSecClassGenericPassword)
        }
        catch  {
            state.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    private func signUpWithEmailPassword() async {
        do  {
            _ = try await auth.createUser(withEmail: state.email,
                                          password: state.password)
        }
        catch {
            state.errorMessage = error.localizedDescription
        }
    }
}


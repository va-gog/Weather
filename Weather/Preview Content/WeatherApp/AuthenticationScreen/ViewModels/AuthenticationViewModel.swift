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
    @State var authenticationState: AuthenticationState = .none
    
    private var coordinator: Coordinator
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private var keychain: KeychainManagerInterface
    private var auth: AuthInterface
        
    init(coordinator: Coordinator,
         auth: AuthInterface = AuthWrapper(),
         keychain: KeychainManagerInterface = KeychainManager()) {
        self.coordinator = coordinator
        self.keychain = keychain
        self.auth = auth
                
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
            password = try keychain.retrieveItem(key: email,
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
}

extension AuthenticationViewModel {
    func signInWithEmailPassword() async -> Bool {
        do {
            _ = try await auth.signIn(withEmail: self.email,
                                      password: self.password)
            try? self.keychain.saveItem(data: self.password.data(using: .utf8),
                                        key: self.email,
                                        secClass: kSecClassGenericPassword)
            return true
        }
        catch  {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func signUpWithEmailPassword() async -> Bool {
        do  {
            _ = try await auth.createUser(withEmail: email, password: password)
            return true
        }
        catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func signAction() async -> Bool {
        authenticationState = .authenticating
        if flow == .login {
            return await signInWithEmailPassword()

        }
        if flow == .signUp {
            return   await signUpWithEmailPassword()
        }
        return false
    }
}


//
//  AuthenticationFlow.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import Foundation

enum AuthenticationFlow: String {
    case login = "Log in"
    case signUp = "Sign up"
    
    var changeModeText: String {
        return switch self {
        case .login:
            NSLocalizedString("Don't have an account yet?", comment: "")
        case .signUp:
            NSLocalizedString("Already have an account?", comment: "")
        }
    }
    
    var titile: String {
        return switch self {
        case .login:
            NSLocalizedString("Login?", comment: "")
        case .signUp:
            NSLocalizedString("Sign up", comment: "")
        }
    }
    
    var next: AuthenticationFlow {
        return switch self {
        case .login:
                .signUp
        case .signUp:
                .login
            
        }
    }
}

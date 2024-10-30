//
//  AuthenticationFlow.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import Foundation

enum AuthenticationFlow {
    case login
    case signUp
    
    var changeModeText: String {
        return switch self {
        case .login:
            LocalizedText.noAccountQuestion
        case .signUp:
            LocalizedText.haveAccountQuestion
        }
    }
    
    var titile: String {
        return switch self {
        case .login:
            LocalizedText.loginQuestion
        case .signUp:
            LocalizedText.signUp
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
    
    var buttonTitle: String {
        return switch self {
        case .login:
            LocalizedText.login
        case .signUp:
            LocalizedText.signUp
        }
    }
}

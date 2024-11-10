//
//  AuthenticationScreenDependencies.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

struct AuthenticationScreenDependencies: AuthenticationScreenDependenciesInterface {
    var keychain: KeychainManagerInterface
    var auth: AuthInterface
}

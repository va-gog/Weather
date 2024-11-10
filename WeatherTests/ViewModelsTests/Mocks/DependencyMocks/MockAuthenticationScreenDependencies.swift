//
//  MockAuthenticationScreenDependencies.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

@testable import Weather

struct MockAuthenticationScreenDependencies: AuthenticationScreenDependenciesInterface {
    var keychain: KeychainManagerInterface
    var auth: AuthInterface
}

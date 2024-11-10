//
//  AuthenticationScreenDependenciesInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

protocol AuthenticationScreenDependenciesInterface {
    var keychain: KeychainManagerInterface { get }
    var auth: AuthInterface { get }
}

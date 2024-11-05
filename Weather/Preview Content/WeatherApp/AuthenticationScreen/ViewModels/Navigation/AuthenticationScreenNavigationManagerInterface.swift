//
//  AuthenticationScreenNavigationManagerInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 05.11.24.
//

protocol AuthenticationScreenNavigationManagerInterface {
    var state: AuthenticationState { get }
    
    func changeState(_ newState: AuthenticationState)
}

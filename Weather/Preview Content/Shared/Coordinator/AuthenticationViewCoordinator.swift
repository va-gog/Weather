//
//  AuthenticationViewCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 15.11.24.
//

import SwiftUI

final class AuthenticationViewCoordinator: CoordinatorInterface {
    var type: AppPages = .authentication
    var parent: (CoordinatorInterface)?
    var childs: [CoordinatorInterface] = []
    
    var dependenciesManager: DependencyManagerInterface
    
    init(dependenciesManager: DependencyManagerInterface) {
        self.dependenciesManager = dependenciesManager
    }
    
    func push(page: AppPages) {}
    
    func pop(pages: [AppPages]) {}

    func build(screen: AppPages) -> AnyView? {
        AnyView(
        AuthenticationView()
            .environmentObject(AuthenticationViewModel(dependenciesManager: dependenciesManager))
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        )
    }
}

//
//  LocationPermitionScreenCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 15.11.24.
//

import SwiftUI

struct LocationPermitionScreenCoordinator: CoordinatorInterface {
    var type: AppPages = .locationAccess
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
            LocationPermitionView()
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        )
    }
}

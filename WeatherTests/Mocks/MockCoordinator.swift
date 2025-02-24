//
//  MockCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

@testable import Weather
import SwiftUI

final class MockCoordinator: CoordinatorInterface {    
    var type: any AppScreen
    var parent: (any CoordinatorInterface)?
    var childs: [any CoordinatorInterface] = []
    var pushedPages: [any AppScreen] = []
    var popedPages: [any AppScreen] = []
    var reducer: (any Reducer)?
    var action: (any Action)?

    init(type: any AppScreen) {
        self.type = type
    }
    
    func push(_ screen: any AppScreen) {
        pushedPages.append(screen)
    }
    
    func send(action: any Action) {
        parent?.push(type)
        self.action = action
    }
    
    func pop(_ screens: [any AppScreen]) {
        popedPages.append(contentsOf: screens)
    }
    
    func build(screen: any AppScreen) -> (any View)? {
        EmptyView()
    }
}

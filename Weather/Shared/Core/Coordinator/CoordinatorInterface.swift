//
//  CoordinatorInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 10.11.24.
//

import SwiftUI

protocol CoordinatorInterface: AnyObject {
    var type: any AppScreen { get }
    var parent: (any CoordinatorInterface)? { get }
    var childs: [any CoordinatorInterface] { get }
    
    func push(_ screen: any AppScreen)
    func pop(_ screens: [any AppScreen])
    func build(screen: any AppScreen) -> AnyView?
    func send(action: Action)
}

extension CoordinatorInterface {
    func push(_ screen: any AppScreen) {}
    func pop(_ screens: [any AppScreen]) {}
    func send(action: Action) {}
}


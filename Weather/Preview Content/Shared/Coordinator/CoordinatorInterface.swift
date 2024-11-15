//
//  CoordinatorInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 10.11.24.
//

import SwiftUI

protocol CoordinatorInterface {
    var type: AppPages { get }
    var parent: CoordinatorInterface? { get }
    var childs: [CoordinatorInterface] { get }
    var dependenciesManager: DependencyManagerInterface { get }
    
    func push(page: AppPages)
    func pop(pages: [AppPages])
    func build(screen: AppPages) -> AnyView?
}


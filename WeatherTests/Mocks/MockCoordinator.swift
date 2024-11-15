//
//  MockCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

@testable import Weather
import SwiftUI

final class MockCoordinator: CoordinatorInterface {
    var dependenciesManager: DependencyManagerInterface
    var type: AppPages
    var parent: CoordinatorInterface?
    var childs: [CoordinatorInterface] = []
    var pushedPage: AppPages?
    var popedPages: [AppPages] = []
    
    init(type: AppPages, dependenciesManager: DependencyManagerInterface) {
        self.type = type
        self.dependenciesManager = dependenciesManager
    }
    
    func push(page: AppPages) {
        pushedPage = page
    }
    func pop(pages: [AppPages]) {
        popedPages = pages
    }
    
    func build(screen: AppPages) -> AnyView? {
        AnyView(EmptyView())
    }
}

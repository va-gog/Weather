//
//  MockForecastScreenCoordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 15.11.24.
//

@testable import Weather
import SwiftUI

final class MockForecastScreenCoordinator: ForecastScreenCoordinatorInterface {
    var type: AppPages = .forecast
    var parent: CoordinatorInterface?
    var childs: [CoordinatorInterface] = []
    var dependenciesManager: DependencyManagerInterface
    var currentInfo: WeatherCurrentInfo?
    var popedPage: [AppPages] = []
    var pushedPage: AppPages?
    
    init(dependenciesManager: DependencyManagerInterface) {
        self.dependenciesManager = dependenciesManager
    }
    
    func push(page: AppPages) {
        pushedPage = page
    }
    
    func pop(pages: [AppPages]) {
        popedPage = pages
    }
    
    func build(screen: AppPages) -> AnyView? {
        AnyView(EmptyView())
    }
    
    func cancel() {
        popedPage.append(.forecast)
    }
    
    func signOut() {
        popedPage.append(.forecast)
    }
    
    func closeWhenDeleted(info: WeatherCurrentInfo?) {
        currentInfo = info
        popedPage.append(.forecast)
    }
    
    func closeWhenAdded(info: WeatherCurrentInfo?) {
        currentInfo = info
        popedPage.append(.forecast)
    }
    
}

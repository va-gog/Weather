//
//  Coordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

@propertyWrapper
final class Dependency<T> {
    private var resolvedDependency: T?
    
    public var wrappedValue: T {
        get {
            let dependency: T = resolvedDependency ?? DependencyManager.resolve()
            resolvedDependency = dependency
            return dependency
        }
        set {
            resolvedDependency = newValue
        }
    }
}

extension Dependency {
    public func injectMock(_ mock: T) {
        self.resolvedDependency = mock
    }
}

final class DependencyFactory<T, A> {

    var factory: (A) -> T

    init(_ factory: @escaping (A) -> T) {
        self.factory = factory
    }
}

final class DependencyManager {
    private var factories: [String: AnyObject] = [:]
    private var dependencies = [String: [AnyObject]]()
    private static var shared = DependencyManager()
    
    static func removeAllDependencies() {
        shared.dependencies.removeAll()
    }
    
    static func register<T>(_ type: T.Type, factory: @autoclosure @escaping () -> T) {
        let key = String(describing: T.self)
        shared.factories[key] = DependencyFactory(factory) as AnyObject
    }
    
    static func resolve<T>() -> T {
        resolve(T.self)
    }
    
    private static func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: T.self)
        guard let factory = shared.factories[key] as? DependencyFactory<T, Void> else {
            fatalError("Resolve unregistered service: \(type)")
        }
        return factory.factory(())
    }
}


import SwiftUI

final class AppLaunchScreenCoordinator: CoordinatorInterface, ObservableObject {

    @Published var path: NavigationPath = NavigationPath()
    
    var type: any AppScreen = WeatherAppScreen.launch
    var parent: (any CoordinatorInterface)?
    var childs: [any CoordinatorInterface] = []
    
    func push(_ screen: any AppScreen) {
        switch screen {
        case WeatherAppScreen.locationAccess:
            childs.removeAll()
            path.removeLast(path.count)
            childs.append(LocationPermitionScreenCoordinator())
            path.append(WeatherAppScreen.locationAccess)
        case WeatherAppScreen.main:
            let coordinator = MainScreenCoordinator(parent: self)
            let viewModel = MainScreenViewModel(coordinator: coordinator)
            coordinator.mainScreenViewModel = viewModel
            childs.removeAll()
            path.removeLast(path.count)
            childs.append(coordinator)
            path.append(WeatherAppScreen.main)
        case WeatherAppScreen.authentication:
            childs.removeAll()
            path.removeLast(path.count)
            childs.append(AuthenticationViewCoordinator())
            path.append(WeatherAppScreen.authentication)
            
        default:
            path.append(screen)
            break
        }
    }
    
    func pop(_ screens: [any AppScreen]) {
        guard path.count >= screens.count else { return }
        for screen in screens {
            if let index = childs.firstIndex(where: {$0.type as? WeatherAppScreen == screen as? WeatherAppScreen} ) {
                childs.remove(at: index)
            }
        }
        path.removeLast(screens.count)
    }
    
    func build(screen: any AppScreen) -> AnyView? {
        for child in childs {
            if let view = child.build(screen: screen) {
                return view
            }
        }
        return nil
    }
}

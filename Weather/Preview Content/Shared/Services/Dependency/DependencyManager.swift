//
//  DependencyManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 05.02.25.
//

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

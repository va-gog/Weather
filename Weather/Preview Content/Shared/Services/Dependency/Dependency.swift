//
//  Dependency.swift
//  Weather
//
//  Created by Gohar Vardanyan on 05.02.25.
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

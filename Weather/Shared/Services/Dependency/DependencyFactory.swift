//
//  DependencyFactory.swift
//  Weather
//
//  Created by Gohar Vardanyan on 05.02.25.
//

final class DependencyFactory<T, A> {
    var factory: (A) -> T

    init(_ factory: @escaping (A) -> T) {
        self.factory = factory
    }
}

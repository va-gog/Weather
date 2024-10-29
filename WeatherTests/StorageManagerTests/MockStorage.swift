//
//  MockStorage.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

@testable import Weather
import RealmSwift

final class MockStorage: StorageInterface {
    var storedObjects: [Storable]
    var failure: MockStorageError?
    
    init(storedObjects: [Storable] = []) {
        self.storedObjects = storedObjects
    }
    
    func objects<Element>(_ type: Element.Type) -> [Element] where Element : RealmFetchable {
        return storedObjects.compactMap { $0 as? Element }
    }
    
    func add(_ object: Object, block: (() -> Void)?) throws {
        if let failure { throw failure }
        storedObjects.append(object as! Storable)
        block?()
    }
    
    func write<Result>(withoutNotifying tokens: [NotificationToken], _ block: (() throws -> Result)) throws -> Result? {
        if let failure { throw failure }
        return try block()
    }
}

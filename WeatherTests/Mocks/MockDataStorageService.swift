//
//  MockDataStorageService.swift
//  Weather
//
//  Created by Gohar Vardanyan on 13.11.24.
//

@testable import Weather
import RealmSwift

final class MockDataStorageService: StorageServiceInterface {
    var info: StorableInfo?
    var object: Storable?
    
    func fetchItem<T>(byId id: String, type: T.Type) -> Storable? where T: Object & Storable {
        return object
    }
    
    func addItem(info: StorableInfo, type: Storable.Type, object: Storable) -> Result<Void, Error> {
        self.info = info
        self.object = object
        return .success(())
    }
    
    func removeItem(info: any StorableInfo, type: any Storable.Type, object: any Storable) throws { }
}

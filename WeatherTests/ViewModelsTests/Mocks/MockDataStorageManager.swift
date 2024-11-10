//
//  MockDataStorageManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

@testable import Weather
import Foundation
import RealmSwift

final class MockDataStorageManager: StorageManagerInterface {
    var storageService: StorageServiceInterface
    var coordinates: [Coordinates]?
    var addedItemID: String?
    var storedItem: StorableInfo?
    
    init(storageService: StorageServiceInterface) {
        self.storageService = storageService
    }
    
    func fetchStoredCoordinates(by id: String?) -> [Coordinates] {
        coordinates ?? []
    }
    
    func addItem(with id: String?, info: any StorableInfo) {
        addedItemID = id
        storedItem = info
    }
}

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
}

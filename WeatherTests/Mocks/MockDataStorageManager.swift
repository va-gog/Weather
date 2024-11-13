//
//  MockDataStorageManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

@testable import Weather
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
    
    func removeObject(with id: String?, info: any StorableInfo) {
    }
}

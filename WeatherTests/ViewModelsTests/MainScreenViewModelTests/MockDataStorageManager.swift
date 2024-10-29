//
//  MockDataStorageManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

@testable import Weather
import Foundation
import RealmSwift

class MockDataStorageManager: DataStorageManagerInterface {
    var info: StorableInfo?
    var object: Storable?
    
    func fetchItem<T>(byId id: String, type: T.Type) -> Storable? where T: Object & Storable {
        return object
    }
    
    func addOrUpdateItem(info: StorableInfo, type: Storable.Type, object: Storable) -> Result<Void, Error> {
        self.info = info
        self.object = object
        return .success(())
    }
}

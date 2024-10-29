//
//  StorageManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import RealmSwift
import Foundation

final class StorageManager: DataStorageManagerInterface {
    private var storage: StorageInterface
    
    init(storage: StorageInterface = RealmWrapper()) {
        self.storage = storage
    }
    
    func addOrUpdateItem(info: StorableInfo, type: Storable.Type, object: Storable) -> Result<Void, Error> {
        do {
            if let userInfo = storage.objects(type).filter( { $0.id == object.id }).first {
                try storage.write(withoutNotifying: [], {
                    info.storableObjec(userInfo)
                })
            } else {
                try storage.add(object, block: nil)
            }
            return .success(())
        } catch {
            print("Failed to write to storage: \(error)")
            return .failure(error)
        }
    }
    
    func fetchItem<T: Object & Storable>(byId id: String, type: T.Type) -> Storable? {
        return storage.objects(type).filter( {$0.id == id }).first
    }
}

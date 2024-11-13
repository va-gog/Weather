//
//  StorageService.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

import RealmSwift
import Foundation

final class StorageService: StorageServiceInterface {
    private var storage: StorageInterface
    
    init(storage: StorageInterface = RealmWrapper()) {
        self.storage = storage
    }
    
    func addItem(info: StorableInfo, type: Storable.Type, object: Storable) -> Result<Void, Error> {
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
    
    func removeItem(info: StorableInfo, type: Storable.Type, object: Storable) throws {
        do {
            if let userInfo = storage.objects(type).first(where: { $0.id == object.id }) {
                try storage.write(withoutNotifying: [], {
                    userInfo.removeFromObject(storeInfo: info)
                })
            } 
        } catch let error as StorageError {
            throw error
        } catch {
            throw StorageError.writeFailed(errorDescription: error.localizedDescription)
        }
    }
}

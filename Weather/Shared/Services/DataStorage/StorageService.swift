//
//  StorageService.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

import RealmSwift
import Foundation

final class StorageService: StorageServiceInterface {
    @Dependency private var storage: StorageInterface
    
    func addItem(info: StorableInfo, type: Storable.Type, object: Storable) throws {
        do {
            if let userInfo = storage.objects(type).filter( { $0.id == object.id }).first {
                try storage.write(withoutNotifying: [], {
                    info.updateInfo(userInfo)
                })
            } else {
                try storage.add(object, block: nil)
            }
        } catch {
            print("Failed to write to storage: \(error)")
            throw StorageError.writeFailed(errorDescription: error.localizedDescription)
        }
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
    
    func fetchItem<T: Object & Storable>(byId id: String, type: T.Type) -> Storable? {
        return storage.objects(type).filter( {$0.id == id }).first
    }
}

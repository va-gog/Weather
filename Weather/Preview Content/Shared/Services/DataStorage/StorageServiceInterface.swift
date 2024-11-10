
//
//  StorageServiceInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Foundation
import RealmSwift

protocol StorageServiceInterface {
    func fetchItem<T: Object & Storable>(byId id: String, type: T.Type) -> Storable?
    func addItem(info: StorableInfo, type: Storable.Type, object: Storable) -> Result<Void, Error>
}

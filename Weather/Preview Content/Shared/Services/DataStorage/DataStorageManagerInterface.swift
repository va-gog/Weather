
//
//  DataStorageManagerInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Foundation
import RealmSwift

protocol DataStorageManagerInterface {
    func fetchItem<T: Object & Storable>(byId id: String, type: T.Type) -> Storable?
    func addOrUpdateItem(info: StorableInfo, type: Storable.Type, object: Storable) -> Result<Void, Error>
}

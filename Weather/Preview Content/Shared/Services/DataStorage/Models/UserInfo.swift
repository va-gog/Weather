//
//  UserInfo.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import RealmSwift

class UserInfo: Object, Storable {
    @Persisted var id: String
    @Persisted var coordinates: List<StoreCoordinates>
    
    convenience init(id: String) {
        self.init()
        self.id = id
    }
    
    override init() {
        super.init()
    }
    
    func updateObject(storeInfo: StorableInfo) {
        guard let storeInfo = storeInfo as? StoreCoordinates else { return }
        coordinates.append(storeInfo)
    }
    
    func removeFromObject(storeInfo: StorableInfo) {
        guard let storeInfo = storeInfo as? StoreCoordinates else { return }
        coordinates.remove(at: storeInfo.index)
    }

    func fetchStoredCoordinates() -> [Coordinates] {
        coordinates.map { Coordinates(lon: $0.longitude, lat: $0.latitude) }
    }
}

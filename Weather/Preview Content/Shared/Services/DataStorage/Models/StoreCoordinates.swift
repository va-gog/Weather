//
//  StoreCoordinates.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import RealmSwift

final class StoreCoordinates: Object, Comparable, StorableInfo {
    @Persisted var index: Int
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    
    required init(latitude: Double, longitude: Double, index: Int) {
        self.latitude = latitude
        self.longitude = longitude
        self.index = index
    }
    
    override init() {
        super.init()
    }
    
    static func < (lhs: StoreCoordinates, rhs: StoreCoordinates) -> Bool {
        return lhs.index < rhs.index
    }
    
    static func == (lhs: StoreCoordinates, rhs: StoreCoordinates) -> Bool {
        return lhs.index == rhs.index
        && lhs.latitude == rhs.latitude
        && lhs.longitude == rhs.longitude
    }
    
    func storableObjec(_ object: Storable) {
        (object as? UserInfo)?.coordinates.append(self)
    }
    
}

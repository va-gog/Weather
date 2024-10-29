//
//  Storable.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

import RealmSwift

protocol Storable: Object {
   var id: String { get }
    
    func updateObject(storeInfo: StorableInfo)
}

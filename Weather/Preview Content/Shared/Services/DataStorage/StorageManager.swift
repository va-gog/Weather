//
//  StorageManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import RealmSwift
import Foundation

struct StorageManager: StorageManagerInterface {
    var storageService: StorageServiceInterface
    
    func fetchStoredCoordinates(by id: String?) -> [Coordinates] {
        let object = storageService.fetchItem(byId: id ?? "",
                                              type: UserInfo.self)
        return (object as? UserInfo)?.fetchStoredInfo() as? [Coordinates] ?? []
    }
    
    func addItem(with id: String?, info: StorableInfo) {
        let newUserInfo = UserInfo(id: id ?? "")
        
        try? storageService.addItem(info: info,
                                   type: UserInfo.self,
                                   object: newUserInfo)
    }
    
    func removeObject(with id: String?, info: StorableInfo) {
        let newUserInfo = UserInfo(id: id ?? "")

        try? storageService.removeItem(info: info,
                                       type: UserInfo.self,
                                       object: newUserInfo)
    }
}

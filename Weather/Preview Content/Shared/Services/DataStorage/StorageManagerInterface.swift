//
//  StorageManagerInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

import Foundation

protocol StorageManagerInterface {
    var storageService: StorageServiceInterface { get }
    
    func fetchStoredCoordinates(by id: String?) -> [Coordinates]
    func addItem(with id: String?, info: StorableInfo)
}

//
//  StoreInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import RealmSwift

protocol StorageInterface {
    func objects<Element: RealmFetchable>(_ type: Element.Type) -> [Element]
    func add(_ object: Object, block: (() -> Void)?) throws
    func write<Result>(withoutNotifying tokens: [NotificationToken], _ block: (() throws -> Result)) throws -> Result?
}

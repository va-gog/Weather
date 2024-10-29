//
//  RealmWrapper.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import RealmSwift

struct RealmWrapper: StorageInterface {
    private let config = Realm.Configuration(
        schemaVersion: 5,
        migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < 5 {
                migration.enumerateObjects(ofType: StoreCoordinates.className()) { oldObject, newObject in
                    newObject?["index"] = 0
                }
                migration.enumerateObjects(ofType: UserInfo.className()) { oldObject, newObject in
                    newObject?["id"] = ""
                }
            }
        }
    )
    
    init() {
        Realm.Configuration.defaultConfiguration = config
    }
    
    func objects<Element: RealmFetchable>(_ type: Element.Type) -> [Element] {
        guard let realm = try? Realm() else {
            print("Failed to initialize Realm and fetch info")
            return []
        }
        return Array( realm.objects(type) )
    }
    
    func add(_ object: Object, block: (() -> Void)?) throws {
        do {
            let realm = try Realm()
            try realm.write() {
                block?()
                realm.add(object)
            }
        } catch let error {
            print("Failed to add data in Realm:", error.localizedDescription)
            throw error
        }
    }
    
    func write<Result>(withoutNotifying tokens: [NotificationToken], _ block: (() throws -> Result)) throws -> Result? {
        do {
            let realm = try Realm()
            return try realm.write() {
                try block()
            }
        } catch {
            print("Failed to write data in Realm:", error.localizedDescription)
            throw error
        }
    }
    
}

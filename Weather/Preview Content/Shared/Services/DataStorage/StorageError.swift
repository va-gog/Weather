//
//  StorageError.swift
//  Weather
//
//  Created by Gohar Vardanyan on 12.11.24.
//

enum StorageError: Error {
    case initializationFailed
    case fetchFailed
    case deleteFailed
    case writeFailed(errorDescription: String)
    case migrationFailed(errorDescription: String)
    
    var localizedDescription: String {
        switch self {
        case .initializationFailed:
            return "Failed to initialize Realm."
        case .fetchFailed:
            return "Failed to fetch objects from Realm."
        case .deleteFailed:
            return "Failed to delete objects from Realm."
        case .writeFailed(let errorDescription):
            return "Failed to write data to Realm: \(errorDescription)"
        case .migrationFailed(let errorDescription):
            return "Realm migration failed: \(errorDescription)"
        }
    }
}

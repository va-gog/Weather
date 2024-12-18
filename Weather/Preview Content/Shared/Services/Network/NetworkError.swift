//
//  NetworkError.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Foundation

enum NetworkError: Error, Equatable {
    case badURL
    case requestFailed
    case decodingFailed
    case unknown(Error)
    
    static func networkError(from error: Error) -> NetworkError {
        if let decodingError = error as? DecodingError {
            return NetworkError.unknown(decodingError)
        }
        return error as? NetworkError ?? NetworkError.unknown(error)
    }
    
    static func ==(lhs: NetworkError, rhs: NetworkError) -> Bool {
           switch (lhs, rhs) {
           case (.badURL, .badURL):
               return true
           case (.requestFailed, .requestFailed):
               return true
           case (.decodingFailed, .decodingFailed):
               return true
           case (.unknown(let lhsError), .unknown(let rhsError)):
               return lhsError.localizedDescription == rhsError.localizedDescription
           default:
               return false
           }
       }
}

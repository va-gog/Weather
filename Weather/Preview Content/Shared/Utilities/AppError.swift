//
//  AppError.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

enum AppError: Error, Equatable {
    case locationFetchFail
    case weatherFetchFail
    case failure(Error)
    
    static func convertToFetchError(error: Error) -> AppError {
        if let fetchError = error as? AppError {
           return fetchError
        }  else if error is LocationError {
            return .locationFetchFail
        }
         return .failure(error)
    }
    
    static func ==(lhs: AppError, rhs: AppError) -> Bool {
           switch (lhs, rhs) {
           case (.locationFetchFail, .locationFetchFail):
               return true
           case (.weatherFetchFail, .weatherFetchFail):
               return true
           case (.failure(let lhsError), .failure(let rhsError)):
               return type(of: lhsError) == type(of: rhsError)
           default:
               return false
           }
       }
}

//
//  LocationAuthorizationFetchStatus.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

 import CoreLocation

enum LocationAuthorizationStatus: Equatable {
    case authorized
    case denied
    case notDetermined
    
    static func authorizationStatus(_ status: CLAuthorizationStatus) -> LocationAuthorizationStatus {
        return switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            LocationAuthorizationStatus.authorized
        case .denied, .restricted:
            LocationAuthorizationStatus.denied
        default:
           .notDetermined
        }
    }
}

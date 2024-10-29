//
//  MockLocationService.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

import Combine
import CoreLocation
@testable import Weather

class MockLocationService: LocationServiceInterface {
    var latestLocationObject = PassthroughSubject<CLLocation, LocationError>()
    var statusSubject = PassthroughSubject<LocationAuthorizationStatus, Never>()

    var shouldFail = false 

    func startTracking() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldFail {
                self.latestLocationObject.send(completion: .failure(LocationError.noLocationAvailable))
            } else {
                self.latestLocationObject.send(CLLocation(latitude: 50.0, longitude: -50.0))
                self.latestLocationObject.send(completion: .finished)
            }
        }
    }
}

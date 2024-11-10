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
    var statusSubject = CurrentValueSubject<LocationAuthorizationStatus, Never>(.notDetermined)
    var requestWhenInUseAuthorizationCalled = false
    var shouldFail = false
    var startedTracking = false

    func startTracking() {
        startedTracking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.shouldFail {
                self.latestLocationObject.send(completion: .failure(LocationError.noLocationAvailable))
            } else {
                self.latestLocationObject.send(CLLocation(latitude: 50.0, longitude: -50.0))
                self.latestLocationObject.send(completion: .finished)
            }
        }
    }
    
    func change(status: LocationAuthorizationStatus) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.statusSubject.send(status)
        }
    }
    
    
    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCalled = true
    }
}

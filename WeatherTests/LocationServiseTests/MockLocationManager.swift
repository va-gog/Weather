//
//  MockLocationManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

@testable import Weather
import CoreLocation

class MockLocationManager: LocationManagerInterface {
    var delegate: (any CLLocationManagerDelegate)?
    var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locations: [CLLocation] = []
    var shouldFailWithError: Error? = nil
    var authorizationRequested = false
    var startedUpdatingLocation = false
    
    func startUpdatingLocation() {
        startedUpdatingLocation = true
    }
    
    func stopUpdatingLocation() {}
    
    func requestWhenInUseAuthorization() {
        authorizationRequested = true
    }
}

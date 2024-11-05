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
    
    var started = false
    
    func startUpdatingLocation() {
        started = true
    }
    
    func stopUpdatingLocation() {}
    
    func requestWhenInUseAuthorization() {}
}

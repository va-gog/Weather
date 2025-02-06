//
//  LocationService.swift
//  Weather
//
//  Created by Gohar Vardanyan on 23.10.24.
//

import CoreLocation
import Combine

final class LocationService: NSObject, CLLocationManagerDelegate, LocationServiceInterface {
    var latestLocationObject = PassthroughSubject<CLLocation, LocationError>()
    var statusSubject = CurrentValueSubject<LocationAuthorizationStatus, Never>(LocationAuthorizationStatus.notDetermined)
    
    @Dependency private var manager: LocationManagerInterface
    
    override init() {
        super.init()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        self.manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            latestLocationObject.send(completion: .failure(LocationError.noLocationAvailable))
            return
        }
        manager.stopUpdatingLocation()
        latestLocationObject.send(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        latestLocationObject.send(completion: .failure(LocationError.noLocationAvailable))
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        statusSubject.send(LocationAuthorizationStatus.authorizationStatus(status))
    }
}

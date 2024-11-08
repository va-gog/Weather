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
    
    private var manager: LocationManagerInterface
    private var lastLocation: CLLocation?
    
    init(manager: LocationManagerInterface = CLLocationManager()) {
        self.manager = manager
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
        if let lastLocation = lastLocation {
            let distance = location.distance(from: lastLocation)
            if distance < 500 {
                return
            }
        }
        manager.stopUpdatingLocation()
        lastLocation = location
        self.latestLocationObject.send(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        latestLocationObject.send(completion: .failure(LocationError.noLocationAvailable))
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            statusSubject.send(.authorized)
        case .denied, .restricted:
            statusSubject.send(.denied)
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

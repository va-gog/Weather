//
//  LocationService.swift
//  Weather
//
//  Created by Gohar Vardanyan on 23.10.24.
//

import CoreLocation
import Combine

final class LocationService: NSObject, CLLocationManagerDelegate, LocationServiceInterface {
    private var manager: LocationManagerInterface
    var latestLocationObject = PassthroughSubject<CLLocation, LocationError>()
    
    init(manager: LocationManagerInterface = CLLocationManager()) {
        self.manager = manager
        super.init()
        self.manager.delegate = self
        self.manager.requestWhenInUseAuthorization()
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startTracking() {
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            latestLocationObject.send(completion: .failure(LocationError.noLocationAvailable))
            return
        }
        latestLocationObject.send(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        latestLocationObject.send(completion: .failure(LocationError.noLocationAvailable))
    }
}

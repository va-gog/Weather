//
//  LocationManagerInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import CoreLocation

protocol LocationManagerInterface {
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func requestWhenInUseAuthorization()
    
    var delegate: (any CLLocationManagerDelegate)? { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
}

extension CLLocationManager: LocationManagerInterface { }

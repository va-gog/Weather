//
//  LocationServiceInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Combine
import CoreLocation

protocol LocationServiceInterface {
    var latestLocationObject: PassthroughSubject<CLLocation, LocationError> { get }
    func startTracking()
}

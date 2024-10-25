//
//  WeatherInfoToPresentationInfoConverter.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Foundation

struct WeatherInfoToPresentationInfoConverter {
    var decimalPlaces: Int = 0
    
    func temperatureRange(tempMax: Double, tempMin: Double, metric: WeatherUnit) -> String {
        let highTemp = formatDoubleToString(value: tempMax)
        let high = NSLocalizedString("H", comment: "") + ":" + "\(highTemp)\(metric)"
        
        let lowTemp = formatDoubleToString(value: tempMin)
        let low = NSLocalizedString("L", comment: "") + ":" + "\(lowTemp)\(metric)"

       return high + low
    }
    
    func currentLocationTitle(isMyLocation: Bool, name: String) -> String {
        isMyLocation ? NSLocalizedString("My Location", comment: "") : name
    }
    
    func formatDoubleToString(value: Double, decimalPlaces: Int = 0) -> String {
        DoubleToStringConverter().formatDoubleToString(value: value, decimalPlaces: decimalPlaces)
    }
    
    func convertTemperatureToText(temp: Double, unit: WeatherUnit) -> String {
        let temp = formatDoubleToString(value: temp)
        return temp + unit.metric
    }
    
}

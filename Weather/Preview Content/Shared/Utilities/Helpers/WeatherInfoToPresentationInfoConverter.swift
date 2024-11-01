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
        let high = LocalizedText.high + " :" + "\(highTemp)\(metric.metric)"
        
        let lowTemp = formatDoubleToString(value: tempMin)
        let low = LocalizedText.low + " :" + "\(lowTemp)\(metric.metric)"

       return high + " " + low
    }
    
    func currentLocationTitle(isMyLocation: Bool, name: String) -> String {
        isMyLocation ? LocalizedText.myLocation : name
    }
    
    func formatDoubleToString(value: Double, decimalPlaces: Int = 0) -> String {
        DoubleToStringConverter().formatDoubleToString(value: value, decimalPlaces: decimalPlaces)
    }
    
    func convertTemperatureToText(temp: Double, unit: WeatherUnit) -> String {
        let temp = formatDoubleToString(value: temp)
        return temp + unit.metric
    }
    
}

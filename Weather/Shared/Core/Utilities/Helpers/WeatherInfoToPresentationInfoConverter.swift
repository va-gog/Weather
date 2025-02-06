//
//  WeatherInfoToPresentationInfoConverter.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Foundation

protocol WeatherInfoToPresentationInfoConverterInterface {
    var decimalPlaces: Int { get }

    func temperatureRange(tempMax: Double, tempMin: Double, metric: WeatherUnit) -> String
    func currentLocationTitle(isMyLocation: Bool, name: String) -> String
    func formatDoubleToString(value: Double) -> String
    func convertTemperatureToText(temp: Double, unit: WeatherUnit) -> String
    func weatherIcon(for condition: String?) -> String 
}

struct WeatherInfoToPresentationInfoConverter: WeatherInfoToPresentationInfoConverterInterface {
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
    
    func formatDoubleToString(value: Double) -> String {
        DoubleToStringConverter().formatDoubleToString(value: value, decimalPlaces: decimalPlaces)
    }
    
    func convertTemperatureToText(temp: Double, unit: WeatherUnit) -> String {
        let temp = formatDoubleToString(value: temp)
        return temp + unit.metric
    }
    
    func weatherIcon(for condition: String?) -> String {
        guard let condition, let cond = Conditions(rawValue: condition)?.icon else {
            return ""
        }
        return cond
    }
    
}

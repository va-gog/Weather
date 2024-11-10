//
//  MockWeatherInfoToPresentationInfoConverter.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

@testable import Weather

struct MockWeatherInfoToPresentationInfoConverter: WeatherInfoToPresentationInfoConverterInterface  {
    var decimalPlaces: Int = 0

    func temperatureRange(tempMax: Double, tempMin: Double, metric: WeatherUnit) -> String { "" }
    
    func currentLocationTitle(isMyLocation: Bool, name: String) -> String {  LocalizedText.myLocation }
    
    func formatDoubleToString(value: Double) -> String { "" }
    
    func convertTemperatureToText(temp: Double, unit: WeatherUnit) -> String { "20F"}
    
    func weatherIcon(for condition: String?) -> String { "icon" }
}

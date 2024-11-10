//
//  FakeWeatherCurrentInfo.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

@testable import Weather

struct FakeWeatherCurrentInfo {
   static func fakeWeatherCurrentInfo(name: String = "Test",
                                      unit: WeatherUnit = .celsius,
                                isMyLocation: Bool = false) -> WeatherCurrentInfo {
       return WeatherCurrentInfo(currentWeather: Self.fakeCurrentInfo(name: name),
                                      unit: unit,
                                      isMyLocation: isMyLocation)
    }
    
    static func fakeCurrentInfo(name: String = "Test") -> CurrentWeather {
        return CurrentWeather(id: 123,
                                            name: name,
                                            weather: [Weather(main: "Rain",
                                                              icon: "")],
                                            main: Main(temp: 5,
                                                       tempMin: 2,
                                                       tempMax: 3),
                                            coord: Coordinates(lon: 10, lat: 10))
    }
    
    static func fakeWeatherForecast(name: String = "Test", temp: Double = 10) -> WeatherForecast {
        WeatherForecast(hourly: [HourlyWeather(name: name,
                                               temp: temp,
                                               weather: [Weather(main: "Rain",
                                                                           icon: "")])],
                        daily: [DailyWeather(name: name,
                                             temp: Temperature(min: 10,
                                                               max: 20),
                                             weather: [Weather(main: "Rain",
                                                              icon: "")])])
    }

}

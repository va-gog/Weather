//
//  HourlyWeather.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Foundation

struct HourlyWeather: Decodable, Identifiable {
    var id: UUID
    var name: String
    let temp: Double
    let weather: [Weather]
    
    enum CodingKeys: String, CodingKey {
        case id, dt, temp, weather
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id =  UUID()
        self.temp = try container.decode(Double.self, forKey: .temp)
        self.weather = try container.decode([Weather].self, forKey: .weather)
        
        let dt = try container.decode(TimeInterval.self, forKey: .dt)
        let date = Date(timeIntervalSince1970: dt)
        name = DateToStringConverter().convertHour(date: date)
    }
    
    init(id: UUID = UUID(), name: String, temp: Double, weather: [Weather] = []) {
        self.id = id
        self.name = name
        self.temp = temp
        self.weather = weather
    }
}

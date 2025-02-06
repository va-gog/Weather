//
//  City.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Foundation

struct City: Decodable, Hashable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String?
    let state: String?

    enum CodingKeys: String, CodingKey {
        case name, lat, lon, country, state
    }
    
    init(name: String, lat: Double, lon: Double, country: String? = nil, state: String? = nil) {
        self.name = name
        self.lat = lat
        self.lon = lon
        self.country = country
        self.state = state
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        lat = try container.decode(Double.self, forKey: .lat)
        lon = try container.decode(Double.self, forKey: .lon)
        state = try? container.decode(String.self, forKey: .state)
        
        let countryCode = try container.decode(String.self, forKey: .country)
        country = Locale.current.localizedString(forRegionCode: countryCode) ?? countryCode
    }
}

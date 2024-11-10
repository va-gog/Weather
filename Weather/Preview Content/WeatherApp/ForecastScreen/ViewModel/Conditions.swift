//
//  Conditions.swift
//  Weather
//
//  Created by Gohar Vardanyan on 09.11.24.
//

enum Conditions: String {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
    case snow = "Snow"
    
    var icon: String {
        switch self {
        case .clear:
            return AppIcons.clear
        case .clouds:
            return  AppIcons.clouds
        case .rain:
            return  AppIcons.rain
        case .snow:
            return  AppIcons.snow
        }
    }
}

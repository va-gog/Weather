//
//  URLFactory.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

class URLFactory {
    static func url(for urlKey: URLKeys) -> String {
        return appendBasePath(for: urlKey) +
        appendURLPath(for: urlKey)
    }
    
    static func appendAPIKey(for urlKey: URLKeys) -> String {
        return switch urlKey {
        case .current,
                .forecast,
             .geo:
          APIKey.weatherAPI.rawValue
        }
    }
    
    private static func appendBasePath(for urlKey: URLKeys) -> String {
        return switch urlKey {
        case .current,
             .forecast,
             .geo:
            BasePaths.weatherAPI.rawValue
        }
    }
    
    private static func appendURLPath(for urlKey: URLKeys) -> String {
        return switch urlKey {
        case .current:
            URLPaths.current.rawValue
        case .forecast:
            URLPaths.forecast.rawValue
        case .geo:
            URLPaths.geo.rawValue
        }
    }
}

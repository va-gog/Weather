//
//  GeolocationsRequest.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

struct GeolocationsRequest: NetworkRequest {
    private var geo: String
    
    init(geo: String) {
        self.geo = geo
    }
    
    var path: String {
        let path = URLFactory.url(for: .geo)
        let key = URLFactory.appendAPIKey(for: .geo)
       let queryString = "?q=\(geo)&appid=\(key)"
        return path + queryString
   }
}

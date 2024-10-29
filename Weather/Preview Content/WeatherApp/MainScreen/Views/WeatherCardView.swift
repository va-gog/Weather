//
//  WatherCardView.swift
//  TheWeather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import SwiftUI

struct WeatherCardView: View {
    var info: WeatherCardViewInfo
    var presentationInfo: WeatherCardViewPresentationInfo
    
    private let columns = [
        GridItem(.flexible(),
                 alignment: .leading),
        GridItem(.flexible(),
                 alignment: .trailing)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns,
                  spacing: presentationInfo.spacing) {
            VStack(alignment: .leading) {
                Text(info.myLocation ?? info.location)
                    .font(.headline)
                    .foregroundColor(.white)
                if info.myLocation != nil {
                    Text(info.location)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(presentationInfo.textViewOpaciy))
                }
            }
            Text(info.temperature)
                .font(.system(size: presentationInfo.temperatureTextSize))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity,
                       alignment: .trailing)
            
            Text(info.description)
                .foregroundColor(.white.opacity(presentationInfo.textViewOpaciy))
                .frame(maxWidth: .infinity,
                       alignment: .leading)
            
            Text(info.tempRangeDescription)
                .foregroundColor(.white.opacity(presentationInfo.textViewOpaciy))
                .frame(maxWidth: .infinity,
                       alignment: .trailing)
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.black]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        )
        .cornerRadius(presentationInfo.cornerRadius)
        .frame(height: presentationInfo.height)
    }
}



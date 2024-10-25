//
//  WatherCardView.swift
//  TheWeather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import SwiftUI

struct WeatherCardView: View {
    var presentationInfo: WeatherCardViewPresentationInfo
    
    private let columns = [
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .trailing)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            VStack(alignment: .leading) {
                Text(presentationInfo.myLocation ?? presentationInfo.location)
                    .font(.headline)
                    .foregroundColor(.white)
                if presentationInfo.myLocation != nil {
                    Text(presentationInfo.location)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            Text(presentationInfo.temperature)
                .font(.system(size: 44))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            Text(presentationInfo.description)
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(presentationInfo.tempRangeDescription)
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .frame(height: 120)
    }
}



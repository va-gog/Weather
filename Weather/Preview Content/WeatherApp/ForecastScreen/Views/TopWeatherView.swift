//
//  TopWeatherView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import SwiftUI

struct TopWeatherView: View {
    var presentationInfo: TopViewPresentationInfo
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(presentationInfo.name)
                    .font(.caption2)
                    .bold()
                Text(presentationInfo.temperature)
                    .font(.system(size: 40))
                
                if presentationInfo.isMyLocation {
                    Text(presentationInfo.name)
                        .font(.body)
                        .bold()
                }
            }
            Spacer()
            Image(systemName: presentationInfo.icon)
                .renderingMode(.original)
                .font(.system(size: 50))
                .shadow(radius: 5)
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.2))
        .foregroundColor(.primary)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

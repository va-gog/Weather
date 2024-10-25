//
//  HourlyForecastView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import SwiftUI

struct HourlyForecastView: View {
    var presentationInfo: HourlyForecastViewPresentationInfo

    var body: some View {
        VStack(spacing: 10) {
            Text(presentationInfo.name)
                .font(.caption2)
            Image(systemName: presentationInfo.icon)
                .renderingMode(.original)
                .shadow(radius: 3)
            Text(presentationInfo.temperature)
                .bold()
        }
        .frame(minWidth: 10, minHeight: 80)
        .padding()
        .background(Color(.systemBackground).opacity(0.2))
        .foregroundColor(.primary)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

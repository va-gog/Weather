//
//  HourlyForecastView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import SwiftUI

struct HourlyForecastViewPresentationInfo {
    var spacing: CGFloat = 10
    var minWidth: CGFloat = 10
    var minHeight: CGFloat = 80
    var cornerRadius: CGFloat = 20
    var backgroundColor = UIColor.systemBackground
    var backgroundOpacity: CGFloat = 0.2
    var foregroundColor = Color.primary
    
    var hourTextFonrSize: CGFloat = 11

    var temperatureTextBoldIsActive = true

    var imageRenderingMode = Image.TemplateRenderingMode.original
    var imageShadowRadius: CGFloat = 3.0
}

struct HourlyForecastView: View {
    var info: HourlyForecastViewInfo
    var presentationInfo: HourlyForecastViewPresentationInfo
    
    var body: some View {
        VStack(spacing: presentationInfo.spacing) {
            Text(info.name)
                .font(.caption2)
                .font(.system(size: presentationInfo.hourTextFonrSize))
            Image(systemName: info.icon)
                .renderingMode(presentationInfo.imageRenderingMode)
                .shadow(radius: presentationInfo.imageShadowRadius)
            Text(info.temperature)
                .bold(presentationInfo.temperatureTextBoldIsActive)
        }
        .frame(minWidth: presentationInfo.minWidth,
               minHeight: presentationInfo.minHeight)
        .padding()
        .background(Color(presentationInfo.backgroundColor)
            .opacity(presentationInfo.backgroundOpacity))
        .foregroundColor(presentationInfo.foregroundColor)
        .background(.ultraThinMaterial)
        .cornerRadius(presentationInfo.cornerRadius)
    }
}

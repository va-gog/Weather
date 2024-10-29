//
//  TopWeatherView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import SwiftUI

struct TopWeatherView: View {
    var info: TopViewInfo
    var presentationInfo: TopWeatherViewPresentationInfo

    var body: some View {
        HStack {
            VStack(
                alignment: .leading,
                spacing: presentationInfo.spacing
            ) {
                Text(info.name)
                    .font(.system(size: presentationInfo.nameTextSize))
                    .bold(presentationInfo.nameTextBoldIsActive)
                Text(info.temperature)
                    .font(.system(size: presentationInfo.temperatureTextSize))

                if info.isMyLocation {
                    Text(info.city)
                        .font(.system(size: presentationInfo.cityTextSize))
                        .bold(presentationInfo.cityTextBoldIsActive)
                }
            }
            Spacer()
            Image(systemName: info.icon)
                .renderingMode(presentationInfo.imageRenderMode)
                .font(.system(size: presentationInfo.imageSize))
                .shadow(radius: presentationInfo.imageShadow)
        }
        .padding()
        .background(
            Color(presentationInfo.backgroundColor)
                .opacity(presentationInfo.backgroundOpacity)
        )
        .foregroundColor(presentationInfo.foregroundColor)
        .background(.ultraThinMaterial)
        .cornerRadius(presentationInfo.cornerRadius)
    }
}

//
//  DailyForecastView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import SwiftUI

struct DailyForecastView: View {
    var info: DailyForecastViewInfo
    var presentationInfo: DailyForecastViewpresentationInfo

    var body: some View {
        HStack {
            HStack {
                Text(info.name)
                Spacer()
            }
            Spacer()
            HStack {
                Image(systemName:  info.icon)
               
                    .renderingMode(presentationInfo.imageRenderMode)
                    .shadow(radius: presentationInfo.imageShodow)
                Text(info.dailyForecast)
                Spacer()
            }
            Spacer()

            HStack {
                Text(info.tempMin)
                Text(info.tempMax)
            }
            .bold(presentationInfo.rangeTextBoldIsActive)
          
        }
        .padding()
    }
}

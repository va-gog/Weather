//
//  DailyForecastView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import SwiftUI

struct DailyForecastView: View {
    var presentationInfo: DailyForecastViewPresentationInfo

    var body: some View {
        HStack {
            HStack {
                Text(presentationInfo.name)
                Spacer()
            }
            Spacer()
            HStack {
                Image(systemName:  presentationInfo.icon)
               
                    .renderingMode(.original)
                    .shadow(radius: 5)
                Text(presentationInfo.dailyForecast)
                Spacer()
            }
            Spacer()

            HStack {
                Spacer()
                Text(presentationInfo.tempMin)
                Text(presentationInfo.tempMax)
                Spacer()
            }
            .bold()
          
        }
        .padding()
    }
}

//
//  WeatherView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 24.10.24.
//


import SwiftUI
import Combine
  
struct WeatherDetailsView: View {
    @StateObject var viewModel: WeatherDetailsViewModel
    var presentationInfo: WeatherDetailsViewPresentationInfo
        
    var body: some View {
        presentationInfo.backgroundColor
            .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                ZStack {

                VStack(spacing: presentationInfo.spacing) {
                    if let topViewInfo = viewModel.topViewPresentationInfo() {
                        TopWeatherView(info: topViewInfo,
                                       presentationInfo: TopWeatherViewPresentationInfo())
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.forecastInfo.hourly.indices, id: \.self) { index in
                                if let hourlyViewPresentationInfo = viewModel.hourlyViewPresentationInfo(index: index) {
                                    HourlyForecastView(info: hourlyViewPresentationInfo,
                                                       presentationInfo: HourlyForecastViewPresentationInfo())
                                }
                            }
                        }
                    }
                    
                    LazyVStack(alignment: .leading) {
                        ForEach(viewModel.forecastInfo.daily.indices, id: \.self) { index in
                            if let dailyViewInfo = viewModel.dailyViewPresentationInfo(index: index) {
                                DailyForecastView(info: dailyViewInfo,
                                                  presentationInfo: DailyForecastViewpresentationInfo())
                            }
                        }
                    }
                    .background(Color(presentationInfo.background).opacity(0.2))
                    .foregroundColor(presentationInfo.foregroundColor)
                    .background(.ultraThinMaterial)
                    .cornerRadius(presentationInfo.cornerRadius)
                }
                .padding()
                .onAppear {
                    Task {
                        viewModel.fetchWeatherCurrentInfo()
                    }
                    Task {
                        viewModel.fetchWeatherForecastInfo()
                    }
                }
            }
            
            if viewModel.style == .overlay || viewModel.style == .overlayAdded {
                VStack {
                    TopActionbar(style: viewModel.style,
                                 presentationInfo: TopActionbarPresentationInfo()) { action in
                        viewModel.dismiss()
                        if action == .add {
                            viewModel.addWeatherInfoAsFavorote()
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

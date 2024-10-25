//
//  WeatherView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 24.10.24.
//


import SwiftUI
  
struct WeatherDetailsView: View {
    var viewModel: WeatherDetailsViewModel
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    
                    TopWeatherView(presentationInfo: viewModel.topViewPresentationInfo())
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.forecastInfo.hourly.indices, id: \.self) { index in
                                HourlyForecastView(presentationInfo: viewModel.hourlyViewPresentationInfo(index: index))
                            }
                        }
                    }
                                        
                    VStack(alignment: .leading) {
                        ForEach(viewModel.forecastInfo.daily.indices, id: \.self) { index in
                            DailyForecastView(presentationInfo: viewModel.dailyViewPresentationInfo(index: index))
                        }
                    }
                    .background(Color(.systemBackground).opacity(0.2))
                    .foregroundColor(.primary)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }
                .padding()
                .aspectRatio(1.0, contentMode: .fill)
                .onAppear {
                    
                    let coord = Coordinates(lon: viewModel.currentInfo.currentWeather.coord.lon,
                                            lat: viewModel.currentInfo.currentWeather.coord.lat)
                    viewModel.fetchCurrentLocationWeatherInfo(coordinate: coord)
                }
            }
        }
        .background(Color(.systemBackground).opacity(0.8))
    }
}

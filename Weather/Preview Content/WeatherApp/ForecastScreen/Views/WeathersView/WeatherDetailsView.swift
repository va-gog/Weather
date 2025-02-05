//
//  WeatherView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 24.10.24.
//

import SwiftUI
import Combine

struct WeatherDetailsView: View {
    @EnvironmentObject var viewModel: WeatherDetailsViewModel
    
    var presentationInfo = WeatherDetailsViewPresentationInfo()
    
    var body: some View {
        ZStack {
            presentationInfo.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ScrollView(showsIndicators: false) {
                    
                    ZStack {
                        VStack(spacing: presentationInfo.spacing) {
                            if let topViewInfo = viewModel.topViewPresentationInfo(currentInfo: viewModel.state.currentInfo) {
                                TopWeatherView(info: topViewInfo,
                                               presentationInfo: TopWeatherViewPresentationInfo())
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.state.forecastInfo.hourly.indices, id: \.self) { index in
                                        if let currentInfo = viewModel.state.currentInfo,
                                           let hourlyViewPresentationInfo = viewModel.hourlyViewPresentationInfo(index: index, unit: currentInfo.unit) {
                                            HourlyForecastView(info: hourlyViewPresentationInfo,
                                                               presentationInfo: HourlyForecastViewPresentationInfo())
                                        }
                                    }
                                }
                            }
                            LazyVStack(alignment: .leading) {
                                ForEach(viewModel.state.forecastInfo.daily.indices, id: \.self) { index in
                                    if let currentInfo = viewModel.state.currentInfo,
                                       let dailyViewInfo = viewModel.dailyViewPresentationInfo(index: index,
                                                                                               unit: currentInfo.unit) {
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
                    }
                }
                
                Spacer()
                tabView
            }
            
            .onAppear {
                Task {
                    viewModel.send(WeatherDetailsViewIntent.fetchWeatherCurrentInfo)
                }
                Task {
                    viewModel.send(WeatherDetailsViewIntent.fetchForecastInfo)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.send(WeatherDetailsViewIntent.close)
                }) {
                    Text(LocalizedText.cancel)
                }
            }
            
            if viewModel.style != .overlayAdded {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.send(WeatherDetailsViewIntent.addFavoriteWeather)
                    }) {
                        Text(LocalizedText.add)
                    }
                }
            }
        }
    }

    private var tabView: some View {
        return ToolbarView(settings: ToolbarViewSettings(tabItems: viewModel.bottomToolbarTabs())) { tab in
            switch tab.title {
            case ForecastScreenToolbarTabType.remove.title:
                viewModel.send(WeatherDetailsViewIntent.deleteButtonAction)
            case ForecastScreenToolbarTabType.signOut.title:
                viewModel.send(WeatherDetailsViewIntent.signedOut)
            default:
                assertionFailure("Action for tab item isn't implemented")
            }
        }
    }
}

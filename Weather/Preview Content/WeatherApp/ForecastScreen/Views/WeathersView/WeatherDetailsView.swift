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
    
    var presentationInfo: WeatherDetailsViewPresentationInfo
    
    var body: some View {
        ZStack {
            presentationInfo.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ScrollView(showsIndicators: false) {
                    
                    ZStack {
                        VStack(spacing: presentationInfo.spacing) {
                            if let topViewInfo = viewModel.topViewPresentationInfo(currentInfo: viewModel.currentInfo) {
                                TopWeatherView(info: topViewInfo,
                                               presentationInfo: TopWeatherViewPresentationInfo())
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.forecastInfo.hourly.indices, id: \.self) { index in
                                        if let hourlyViewPresentationInfo = viewModel.hourlyViewPresentationInfo(index: index,
                                                                                                                 currentInfo: viewModel.currentInfo) {
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
                    }
                }
                
                Spacer()
                tabView
            }
            
            .onAppear {
                Task {
                    viewModel.fetchWeatherCurrentInfo()
                }
                Task {
                    viewModel.fetchForecastInfo()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.close()
                    
                }) {
                    Text(LocalizedText.cancel)
                }
            }
            
            if viewModel.presentationStyle() != .overlayAdded {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.addFavoriteWeather()
                    }) {
                        Text(LocalizedText.add)
                    }
                }
            }
        }
    }

    private var tabView: some View {
            ToolbarView<Tab>(selectedTab: nil, onTab: { tab in
                switch tab.title {
                case Tab.remove.title:
                    viewModel.deleteButtonAction()
                case Tab.signOut.title:
                    viewModel.close()
                    try? viewModel.signedOut()
                default:
                    assertionFailure("Action for tab item isn't implemented")
                }
            })
    }
}

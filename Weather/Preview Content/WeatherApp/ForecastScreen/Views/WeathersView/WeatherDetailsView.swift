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
    @Environment(\.dismiss) var dismiss
    
    var presentationInfo: WeatherDetailsViewPresentationInfo
    
    var body: some View {
        ZStack {
            presentationInfo.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ScrollView(showsIndicators: false) {
                    
                    ZStack {
                        VStack(spacing: presentationInfo.spacing) {
                            descriptionView
                            dailyWeatherView
                            weeklyWeatherView
                        }
                        .padding()
                        .onAppear {
                            Task {
                                viewModel.fetchWeatherCurrentInfo()
                            }
                            Task {
                                viewModel.fetchForecastInfo()
                            }
                        }
                    }
                    
                    topActionView                    
                }
                
                Spacer()
                tabView
            }
        }
    }
    
    private var descriptionView: some View {
        VStack {
            if let topViewInfo = viewModel.topViewPresentationInfo(currentInfo: viewModel.currentInfo) {
                TopWeatherView(info: topViewInfo,
                               presentationInfo: TopWeatherViewPresentationInfo())
            }
        }
    }
    
    private var dailyWeatherView: some View {
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
    }
    
    private var weeklyWeatherView: some View {
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
    
    private var tabView: some View {
            ToolbarView<Tab>(selectedTab: nil, onTab: { tab in
                switch tab.title {
                case Tab.remove.title:
                    dismiss()
                    viewModel.deleteButtonAction()
                case Tab.signOut.title:
                    try? viewModel.signedOut()
                    dismiss()
                default:
                    assertionFailure("Action for tab item isn't implemented")
                }
            })
    }
    
    private var topActionView: some View {
        VStack {
            TopActionbar(style: viewModel.presentationStyle(),
                         presentationInfo: TopActionbarPresentationInfo()) { action in
                dismiss()
                if action == .add {
                    viewModel.addFavoriteWeather()
                }
                viewModel.close()
            }
            Spacer()
        }
    }
    
    
}

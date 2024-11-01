//
//  WeatherView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 24.10.24.
//

import SwiftUI
import Combine

struct WeatherDetailsView: View {
    @ObservedObject var coordinator: WeatherDetailsScreenCoordinator
    var presentationInfo: WeatherDetailsViewPresentationInfo

    var body: some View {
        ZStack {
            presentationInfo.backgroundColor
                .edgesIgnoringSafeArea(.all)

            VStack {
                ScrollView(showsIndicators: false) {
                    ZStack {
                        VStack(spacing: presentationInfo.spacing) {
                            if let topViewInfo = coordinator.viewModel.topViewPresentationInfo(currentInfo: coordinator.currentInfo) {
                                TopWeatherView(info: topViewInfo,
                                               presentationInfo: TopWeatherViewPresentationInfo())
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(coordinator.forecastInfo.hourly.indices, id: \.self) { index in
                                        if let hourlyViewPresentationInfo = coordinator.viewModel.hourlyViewPresentationInfo(index: index,
                                                                                                                             currentInfo: coordinator.currentInfo) {
                                            HourlyForecastView(info: hourlyViewPresentationInfo,
                                                               presentationInfo: HourlyForecastViewPresentationInfo())
                                        }
                                    }
                                }
                            }

                            LazyVStack(alignment: .leading) {
                                ForEach(coordinator.viewModel.forecastInfo.daily.indices, id: \.self) { index in
                                    if let dailyViewInfo = coordinator.viewModel.dailyViewPresentationInfo(index: index) {
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
                                coordinator.viewModel.fetchWeatherCurrentInfo()
                            }
                            Task {
                                coordinator.viewModel.fetchWeatherForecastInfo()
                            }
                        }
                    }
                    if coordinator.viewModel.style == .overlay || coordinator.viewModel.style == .overlayAdded {
                        VStack {
                            TopActionbar(style: coordinator.viewModel.style,
                                         presentationInfo: TopActionbarPresentationInfo()) { action in
                                coordinator.viewModel.dismiss()
                                if action == .add {
                                    coordinator.viewModel.addWeatherInfoAsFavorote()
                                }
                            }
                            Spacer()
                        }
                    }
                }

                Spacer()
                ToolbarView<Tab>(selectedTab: nil, onTab: { tab in
                    switch tab.title {
                    case Tab.remove.title:
                        coordinator.viewModel.dismiss()
                        coordinator.deleteButtonPressed()
                    case Tab.signOut.title:
                        coordinator.signoutButtonPressed()
                        coordinator.viewModel.dismiss()
                        print("")
                    default:
                        assertionFailure("Action for tab item isn't implemented")
                    }
                })
            }
        }
    }
}

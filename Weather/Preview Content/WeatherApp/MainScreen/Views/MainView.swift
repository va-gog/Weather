//
//  MainView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import SwiftUI
import Combine
import MapKit
import FirebaseAuth

struct MainView: View {
    @State private var searchText = ""
    
    @State private var searchCancellable: AnyCancellable?
    @State private var searchSubject = PassthroughSubject<String, Never>()
    @State private var isOverlayPresented = false
    @State private var selectedCity: City? = nil
    
    @EnvironmentObject var coordinator: MainScreemCoordinator
    
    private var presentationInfo = MainViewPresentationInfo()
    
    var body: some View {
            if coordinator.locationStatus == .authorized {
                NavigationView {
                    VStack {
                            SearchView(searchText: $searchText,
                                       icon: presentationInfo.searchIcon,
                                       placeholder: presentationInfo.searchPlaceholder,
                                       closeIcon: presentationInfo.closeIcon,
                                       presentationInfo: SearchViewPresentationInfo()) { newValue in
                                searchSubject.send(newValue)
                            }
                           
                        .frame(height: presentationInfo.searchHeight)
                        .background(Color(presentationInfo.searchBackgroundColor))
                        .cornerRadius(presentationInfo.cornerradius)
                        .padding(.horizontal)
                        
                        if searchText.isEmpty {
                            ScrollView {
                                LazyVStack(spacing: presentationInfo.interitemSapec) {
                                    ForEach(coordinator.viewModel.weatherInfo) { info in
                                        let cardInfo = coordinator.viewModel.weatherCardViewPresentationInfo(weatherInfo: info)
                                        WeatherCardView(info: cardInfo, presentationInfo: WeatherCardViewPresentationInfo())
                                            .padding(.horizontal,
                                                     presentationInfo.interitemSapec)
                                            .onTapGesture {
                                                withAnimation {
                                                    coordinator.viewModel.itemSelected(name: info.currentWeather.name)
                                                    selectedCity = City(name: info.currentWeather.name,
                                                                        lat: info.currentWeather.coord.lat,
                                                                        lon: info.currentWeather.coord.lon)
                                                }
                                            }
                                    }
                                }
                                .padding(.vertical, presentationInfo.interitemSapec)
                                .padding(.horizontal, presentationInfo.interitemSapec)
                                
                            }
                        } else {
                            if coordinator.viewModel.searchState == .searching {
                                LoadingView()
                            } else if coordinator.viewModel.searchState == .failed || coordinator.viewModel.searchState == .empty {
                                Spacer()
                                EmptyView(title: NSLocalizedString(LocalizedText.noResultTitle,
                                                                   comment: ""),
                                          subtitle: "\(LocalizedText.noResultSubtitle) '\(searchText)'",
                                          presentationInfo: EmptyViewPresentationInfo())
                                Spacer()
                            } else if coordinator.viewModel.searchState == .success {
                                List(coordinator.viewModel.searchResult, id: \.self) { city in
                                    Text("\(city.name), \(city.country ?? "")")
                                        .onTapGesture {
                                            withAnimation {
                                                coordinator.viewModel.itemSelected(name: city.name)
                                                selectedCity = city
                                            }
                                        }
                                }
                            }
                        }
                        Spacer()
                    }
                    .navigationTitle(presentationInfo.navigationTitle)
                    .navigationBarTitleDisplayMode(.inline)
                }
                .overlay(
                    Group {
                        if let selectedCity, coordinator.viewModel.detailedViewStyle != .dismissed {
                            let model = WeatherDetailsViewModel(selectedCity: selectedCity,
                                                                style: $coordinator.viewModel.detailedViewStyle,
                                                                addedWaetherInfo: coordinator.viewModel.addedWaetherInfo)
                            WeatherDetailsView(coordinator: WeatherDetailsScreenCoordinator(parent: coordinator,
                                                                                            viewModel: model),
                                               presentationInfo: WeatherDetailsViewPresentationInfo())
                            .transition(.move(edge: .bottom))
                        }
                    }
                )
                .onAppear {
                    onApperaAction()
                }
                .onDisappear {
                    searchCancellable?.cancel()
                }
                Spacer()
            } else {
                Spacer()
                notAuthenticatedView
            }

    }
    
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private var notAuthenticatedView: some View {
        VStack {
            Text(LocalizedText.locationAccess)
                .padding()
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text(LocalizedText.openSettings)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
            }
        }
    }
    
    private func onApperaAction() {
        searchCancellable = searchSubject
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { searchTerm in
                coordinator.viewModel.searchWith(query: searchTerm)
            }
        Task {
            coordinator.viewModel.requestNotificationPermission()
            await coordinator.viewModel.fetchWeatherInfo()
        }
    }
    
}

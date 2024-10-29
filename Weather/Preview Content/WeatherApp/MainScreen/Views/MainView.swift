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
    @StateObject var viewModel: MainScreenViewModel
    @State private var searchText = ""
    
    @State private var searchCancellable: AnyCancellable?
    @State private var searchSubject = PassthroughSubject<String, Never>()
    @State private var isOverlayPresented = false
    @State private var selectedCity: City? = nil
    
    var presentationInfo: MainViewPresentationInfo
    
    var body: some View {
        if viewModel.locationStatus == .authorized {
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
                                ForEach(viewModel.weatherInfo) { info in
                                    let cardInfo = viewModel.weatherCardViewPresentationInfo(weatherInfo: info)
                                    WeatherCardView(info: cardInfo, presentationInfo: WeatherCardViewPresentationInfo())
                                        .padding(.horizontal,
                                                 presentationInfo.interitemSapec)
                                        .onTapGesture {
                                            withAnimation {
                                                viewModel.itemSelected(name: nil)
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
                        if viewModel.searchState == .searching {
                            LoadingView()
                        } else if viewModel.searchState == .failed || viewModel.searchState == .empty {
                            Spacer()
                            EmptyView(title: NSLocalizedString("No Results",
                                                               comment: ""),
                                      subtitle: NSLocalizedString("No result found for '\(searchText)'",
                                                                  comment: ""),
                                      presentationInfo: EmptyViewPresentationInfo())
                            Spacer()
                        } else if viewModel.searchState == .success {
                            List(viewModel.searchResult, id: \.self) { city in
                                Text("\(city.name), \(city.country ?? "")")
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.itemSelected(name: city.name)
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
                    if let selectedCity, viewModel.detailedViewStyle != .dismissed {
                        let model = WeatherDetailsViewModel(selectedCity: selectedCity,
                                                            style: $viewModel.detailedViewStyle,
                                                            addedWaetherInfo: viewModel.addedWaetherInfo)
                        WeatherDetailsView(viewModel: model,
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
            Text(NSLocalizedString("Location access is required to use this feature.", comment: ""))
                .padding()
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text(NSLocalizedString("Open Settings", comment: ""))
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
                viewModel.searchWith(query: searchTerm)
            }
        Task {
            viewModel.requestNotificationPermission()
            await viewModel.fetchWeatherInfo()
        }
    }
    
}

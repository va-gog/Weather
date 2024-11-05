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
    @State private var searchSubject = PassthroughSubject<String, Never>()
    @State private var searchCancellable: AnyCancellable?
    
    @EnvironmentObject var viewModel: MainScreenViewModel
    
    private var presentationInfo = MainViewPresentationInfo()
    
    var body: some View {
        if viewModel.locationStatus != .authorized {
            Spacer()
            locationPermitionView
        } else {
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
                    
                    searchResultView
                    Spacer()
                }
                .navigationTitle(presentationInfo.navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
            }
            .overlay(
                Group {
                    if let selectedCity = viewModel.selectedCity,
                       let coordinator = viewModel.navigationManager {
                        let model = WeatherDetailsViewModel(selectedCity: selectedCity,
                                                            style: viewModel.detailsViewPresentationStyle(),
                                                            navigationManager: WeatherDetailsNavigationManager(parent: coordinator))
                        WeatherDetailsView(presentationInfo: WeatherDetailsViewPresentationInfo())
                            .environmentObject(model)
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
        }
        
    }
    
    private var locationPermitionView: some View {
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
    
    private var searchResultView: some View {
        VStack {
            if searchText.isEmpty {
                cardList
            } else {
                if viewModel.searchState == .searching {
                    LoadingView()
                } else if viewModel.searchState == .failed || viewModel.searchState == .empty {
                    Spacer()
                    EmptyView(title: NSLocalizedString(LocalizedText.noResultTitle,
                                                       comment: ""),
                              subtitle: "\(LocalizedText.noResultSubtitle) '\(searchText)'",
                              presentationInfo: EmptyViewPresentationInfo())
                    Spacer()
                } else if viewModel.searchState == .success {
                    List(viewModel.searchResult, id: \.self) { city in
                        Text("\(city.name), \(city.country ?? "")")
                            .onTapGesture {
                                withAnimation {
                                    viewModel.citySelected(city)
                                }
                            }
                    }
                }
            }
        }
    }
    
    private var cardList: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: presentationInfo.interitemSapec) {
                    ForEach(viewModel.weatherInfo) { info in
                        WeatherCardView(info: viewModel.weatherCardViewPresentationInfo(weatherInfo: info),
                                        presentationInfo: WeatherCardViewPresentationInfo())
                        .padding(.horizontal,
                                 presentationInfo.interitemSapec)
                        .onTapGesture {
                            withAnimation {
                                viewModel.weatherSelected(with: info.currentWeather)
                            }
                        }
                    }
                }
                .padding(.vertical, presentationInfo.interitemSapec)
                .padding(.horizontal, presentationInfo.interitemSapec)
            }
        }
    }
    
    private func onApperaAction() {
        searchCancellable = searchSubject
            .debounce(for: .seconds(1),
                      scheduler: RunLoop.main)
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

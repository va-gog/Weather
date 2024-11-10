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
    private let id = UUID()
    @State private var searchText = ""
    @State private var searchSubject = PassthroughSubject<String, Never>()
    @State private var searchCancellable: AnyCancellable?
    @State private var hasAppearedOnce = false
    
    @EnvironmentObject var viewModel: MainScreenViewModel
    
    private var presentationInfo = MainViewPresentationInfo()
    
    var body: some View {
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
            .onAppear {
                onApperaAction()
            }
            .onDisappear {
                searchCancellable?.cancel()
            }
            Spacer()        
    }
    
    private var searchResultView: some View {
        VStack {
            if searchText.isEmpty {
                ScrollView {
                    LazyVStack(spacing: presentationInfo.interitemSapec) {
                        ForEach(viewModel.weatherInfo) { info in
                            WeatherCardView(info: viewModel.weatherCardViewPresentationInfo(weatherInfo: info),
                                            presentationInfo: WeatherCardViewPresentationInfo())
                            .padding(.horizontal,
                                     presentationInfo.interitemSapec)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.weatherSelected(with: info)
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
                    EmptyResultView(title: NSLocalizedString(LocalizedText.noResultTitle,
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
    
    private func onApperaAction() {
        searchCancellable = searchSubject
            .debounce(for: .seconds(1),
                      scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { searchTerm in
                viewModel.searchWith(query: searchTerm)
            }
        Task {
            if !hasAppearedOnce {
                viewModel.requestNotificationPermission()
                await viewModel.fetchWeatherInfo()
                hasAppearedOnce = true
            }
        }
    }
    
}

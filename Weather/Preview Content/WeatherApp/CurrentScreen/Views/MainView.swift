//
//  MainView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import SwiftUI
import Combine
import MapKit

struct MainView: View {
    @StateObject var viewModel: MainScreenViewModel
    @State private var searchText = ""
    
    @State private var searchCancellable: AnyCancellable?
    @State private var searchSubject = PassthroughSubject<String, Never>()
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    TextField("Search for a city or airport", text: $searchText)
                        .foregroundColor(.gray)
                        .onChange(of: searchText) { oldValue, newValue in
                            searchSubject.send(newValue)
                        }
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                    }
                }
                .frame(height: 35)
                .background(Color(.systemGray5))
                .cornerRadius(10)
                .padding(.horizontal)
                
                if searchText.isEmpty {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(viewModel.weatherInfo.indices, id: \.self) { index in
                                NavigationLink(destination: WeatherDetailsView(viewModel: WeatherDetailsViewModel(currentInfo: viewModel.weatherInfo[index]))) {
                                    let presentationInfo = viewModel.weatherCardViewPresentationInfo(weatherInfo:  viewModel.weatherInfo[index])
                                    WeatherCardView(presentationInfo: presentationInfo)
                                        .padding(.horizontal, 10)
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        
                    }
                } else {
                    if searchText != "" {
                        if viewModel.searchState == .searching {
                            Spacer()
                            //TODO: show loader
                        } else if viewModel.searchState == .failed || viewModel.searchState == .empty {
                            //TODO: show empty view
                        } else if viewModel.searchState == .success {
                            List(viewModel.searchResult, id: \.self) { item in
                                Text("\(item.name), \(item.country)")
                            }
                        }
                    }
                }
                Spacer()
            }
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            searchCancellable = searchSubject
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates()
                .sink { searchTerm in
                        viewModel.search(query: searchTerm)
                }
                    Task {
                        await viewModel.fetchWeatherInfo()
                    }
            
        }
        .onDisappear {
            searchCancellable?.cancel()
        }
        Spacer()

    }
}

//
//  WeatherDetailsViewModelTests.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

import XCTest
import Combine
import SwiftUI
@testable import Weather

class WeatherDetailsViewModelTests: XCTestCase {
    var viewModel: WeatherDetailsViewModel!
    var mockNetworkManager: MockNetworkManager!
    var cancellables: Set<AnyCancellable>!
    var style: Binding<WeatherDetailsViewStyle>!

    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        style = Binding.constant(WeatherDetailsViewStyle.dismissed)
        viewModel = WeatherDetailsViewModel(selectedCity: City(name: "Test",
                                                               lat: 10,
                                                               lon: 10),
                                            style: Binding.constant(WeatherDetailsViewStyle.dismissed),
                                            networkManager: mockNetworkManager)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockNetworkManager = nil
        cancellables = nil
        style = nil
        super.tearDown()
    }
    
    func testFetchWeatherCurrentInfoSuccess() async {
        let name = "Test"
        let unit = WeatherUnit.farenheit
        let currentWeather = CurrentWeather(id: 123,
                                            name: name,
                                            weather: [Weather(main: "Main",
                                                              icon: "")],
                                            main: Main(temp: 5,
                                                       tempMin: 2,
                                                       tempMax: 3),
                                            coord: Coordinates(lon: 10, lat: 10))
        mockNetworkManager.stubbedResponse = currentWeather
        
        let expectation = XCTestExpectation(description: "Current weather fetch success")
        XCTAssertNil(self.viewModel.currentInfo)
        
        viewModel.$currentInfo
            .dropFirst()
            .sink { info in
                XCTAssertNotNil(info)
                XCTAssertFalse(info!.isMyLocation)
                XCTAssertEqual(info!.unit, unit)
                XCTAssertEqual(info!.currentWeather.name, name)
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        viewModel.fetchWeatherCurrentInfo(unit: unit)
        
        await fulfillment(of: [expectation], timeout:  5.0)
    }
    
    func testFetchWeatherCurrentInfoFailure() {
        let expectedError = NetworkError.badURL
        mockNetworkManager.stubbedError = expectedError
        let expectation = XCTestExpectation(description: "Current weather fetch fail")
        
        viewModel.$fetchState
            .dropFirst()
            .sink { state in
                switch state {
                case .failed(let error):
                    XCTAssertEqual(error, .failure(expectedError))
                    expectation.fulfill()
                default:
                    XCTFail("Expected Failure")
                    break
                }
            }
            .store(in: &cancellables)

        viewModel.fetchWeatherCurrentInfo(unit: .farenheit)

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testsFetchWeatherForecastInfoSuccess() async {
        let name = "Now"
        let featherForecast = WeatherForecast(hourly: [HourlyWeather(name: name,
                                                                     temp: 14.345)],
                                              daily: [])
        mockNetworkManager.stubbedResponse = featherForecast
        
        let expectation = XCTestExpectation(description: "Forecast weather fetch success")
        
        viewModel.$forecastInfo
            .dropFirst()
            .sink(receiveValue: { info in
                XCTAssertNotNil(info)
                XCTAssertEqual(info.hourly.first?.name, name)
                expectation.fulfill()
                
            })
            .store(in: &cancellables)
        viewModel.fetchWeatherForecastInfo()
        
        await fulfillment(of: [expectation], timeout:  1.0)
    }
    
    func testsFetchWeatherForecastInfoFailure() {
        let expectedError = NetworkError.badURL

        mockNetworkManager.stubbedError = expectedError
        let expectation = XCTestExpectation(description: "Forecast weather fetch fail")
        
        viewModel.$fetchState
            .dropFirst()
            .sink { state in
                switch state {
                case .failed(let error):
                    XCTAssertEqual(error, .failure(expectedError))
                    expectation.fulfill()
                default:
                    XCTFail("Expected Failure")
                    break
                }
            }
            .store(in: &cancellables)

        viewModel.fetchWeatherForecastInfo()

        wait(for: [expectation], timeout: 1.0)
    }

    func testTopViewPresentationInfoFetch() {
        let city = "Test"
        let isMyLocation = true
        let currentWeather = CurrentWeather(id: 123,
                                           name: city,
                                           weather: [Weather(main: "Main",
                                                             icon: "")],
                                           main: Main(temp: 5,
                                                      tempMin: 2,
                                                      tempMax: 3),
                                           coord: Coordinates(lon: 10, lat: 10))
        viewModel.currentInfo = WeatherCurrentInfo(currentWeather: currentWeather,
                                                   isMyLocation: isMyLocation)
        let expectedResult = viewModel.topViewPresentationInfo(currentInfo: viewModel.currentInfo)
        
        XCTAssertNotNil(expectedResult)
        XCTAssertEqual(expectedResult!.city, city)
        XCTAssertEqual(expectedResult!.name, LocalizedText.myLocation)
        XCTAssertTrue(expectedResult!.isMyLocation)
    }
}

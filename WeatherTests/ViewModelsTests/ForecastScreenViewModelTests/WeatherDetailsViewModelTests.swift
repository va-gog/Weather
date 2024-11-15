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
    var mockCoordinator: MockForecastScreenCoordinator!
    var dependenciesManager: MockDependencyManager!
    var mockAuth: MockAuth!
    var cancellables: Set<AnyCancellable>!
    var style: Binding<WeatherDetailsViewStyle>!

    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        mockAuth = MockAuth()
        dependenciesManager = MockDependencyManager(networkService: mockNetworkManager)
        mockCoordinator = MockForecastScreenCoordinator(dependenciesManager: dependenciesManager)
        viewModel = WeatherDetailsViewModel(selectedCity: City(name: "Test",
                                                               lat: 10,
                                                               lon: 10),
                                            style: WeatherDetailsViewStyle.overlay,
                                            coordinator: mockCoordinator,
                                            currentInfo: nil)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockNetworkManager = nil
        mockAuth = nil
        dependenciesManager = nil
        mockCoordinator = nil
        cancellables = nil
        style = nil
        super.tearDown()
    }
    
    func testFetchWeatherCurrentInfoSuccess() async {
        let name = "Test"
        let unit = WeatherUnit.farenheit
        let currentWeather = FakeWeatherCurrentInfo.fakeCurrentInfo(name: name)
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
        viewModel.fetchForecastInfo()
        
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

        viewModel.fetchForecastInfo()

        wait(for: [expectation], timeout: 1.0)
    }

    func testTopViewPresentationInfoFetch() {
        let name = "Test"
        let isMyLocation = true
        viewModel.currentInfo = FakeWeatherCurrentInfo.fakeWeatherCurrentInfo(name: name,
                                                   isMyLocation: isMyLocation)
        let expectedResult = viewModel.topViewPresentationInfo(currentInfo: viewModel.currentInfo)
        
        XCTAssertNotNil(expectedResult)
        XCTAssertEqual(expectedResult!.city, name)
        XCTAssertEqual(expectedResult!.name, LocalizedText.myLocation)
        XCTAssertTrue(expectedResult!.isMyLocation)
    }
    
    func testHourlyViewPresentationInfo_ValidIndex() {
        let index = 0
        let temp = 20.0
        let name = "Monday"
        let forecastInfo = FakeWeatherCurrentInfo.fakeWeatherForecast(name: name,
                                                                      temp: temp)
        viewModel.forecastInfo = forecastInfo
           
        let result = viewModel.hourlyViewPresentationInfo(index: index, unit: .celsius)
           
           XCTAssertNotNil(result)
           XCTAssertEqual(result?.name, name)
           XCTAssertEqual(result?.temperature, "20F")
           XCTAssertEqual(result?.icon, "icon")
       }

       func testHourlyViewPresentationInfo_OutOfBoundsIndex() {
           let index = 5
           
           let result = viewModel.hourlyViewPresentationInfo(index: index, unit: .celsius)
           
           XCTAssertNil(result)
       }

       func testDailyViewPresentationInfo_ValidIndex() {
           let index = 0
           let temp = 20.0
           let name = "Monday"
           let forecastInfo = FakeWeatherCurrentInfo.fakeWeatherForecast(name: name,
                                                                         temp: temp)
           viewModel.forecastInfo = forecastInfo
           
           let result = viewModel.dailyViewPresentationInfo(index: index, unit: .celsius)
           
           XCTAssertNotNil(result)
           XCTAssertEqual(result?.name, name)
           XCTAssertEqual(result?.dailyForecast, "Rain")
           XCTAssertEqual(result?.icon, "icon")
           XCTAssertEqual(result?.tempMin, LocalizedText.high + ":" + "20F")
           XCTAssertEqual(result?.tempMax, LocalizedText.low + ":" + "20F")
       }

       func testDailyViewPresentationInfo_OutOfBoundsIndex() {
           let index = 5
           
           let result = viewModel.dailyViewPresentationInfo(index: index, unit: .celsius)
           
           XCTAssertNil(result)
       }
    
    func testAddFavoriteWeather_WithCurrentInfo() {
        let expectation = XCTestExpectation(description: "Sign out fail")
        let weatherInfo = FakeWeatherCurrentInfo.fakeWeatherCurrentInfo()
        viewModel.currentInfo = weatherInfo
        
        viewModel.addFavoriteWeather()
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.currentInfo?.currentWeather.id,
                           self.mockCoordinator.currentInfo?.currentWeather.id)
            expectation.fulfill()
        }
            
        wait(for: [expectation], timeout: 1)
    }


    func testDeleteButtonAction_WithCurrentInfo() {
        let expectation = XCTestExpectation(description: "Sign out fail")
        let weatherInfo = FakeWeatherCurrentInfo.fakeWeatherCurrentInfo()
        viewModel.currentInfo = weatherInfo
        
        viewModel.deleteButtonAction()
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.currentInfo?.currentWeather.id,
                           self.mockCoordinator.currentInfo?.currentWeather.id)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testSignedOut_Success() throws {
        let expectation = XCTestExpectation(description: "Sign out fail")
        
        try? viewModel.signedOut()
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.mockCoordinator.popedPage, [.forecast])
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        
    }

    func testSignedOut_Failure() {
        mockAuth.signOutError = AppError.signOutFail
        do {
            try self.viewModel.signedOut()
        } catch {
            switch error {
            case AppError.signOutFail:
                XCTAssertTrue(true) 
            default:
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testClose() {
        let expectation = XCTestExpectation(description: "Sign out fail")

        viewModel.close()
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.mockCoordinator.popedPage, [.forecast])
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

    }
}

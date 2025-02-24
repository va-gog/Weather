//
//  MainScreenViewModelTests.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

@testable import Weather
import XCTest
import CoreLocation
import Combine
import SwiftUI

final class MockReducer: Reducer {
    
    final class MockState: ReducerState {
        var action: Action?
    }
    var cancelables: [AnyCancellable] = []
    var state: MockState = MockState()
    
    func send(_ action: Action) {
        state.action = action
    }
}

class MainScreenCoordinatorTests: XCTestCase {
    var coordinator: MainScreenCoordinator!
    var parentCoordinator: MockCoordinator!
    var reducer: MockReducer!

    override func setUp() {
        super.setUp()
        reducer = MockReducer()
        parentCoordinator = MockCoordinator(type: WeatherAppScreen.launch)
        coordinator = MainScreenCoordinator(parent: parentCoordinator)
        coordinator.reducer = reducer
    }

    override func tearDown() {
        super.tearDown()
        reducer = nil
        coordinator = nil
    }
    
    func testCoordinatorSendPushActionToParent() {
        let currentWeather = CurrentWeather(id: 123,
                                            name: "Test",
                                            weather: [Weather(main: "Main",
                                                              icon: "")],
                                            main: Main(temp: 5,
                                                       tempMin: 2,
                                                       tempMax: 3),
                                            coord: Coordinates(lon: 10, lat: 10))
        let city = City(name: "Test", lat: 10, lon: 10)
        let info = WeatherCurrentInfo(currentWeather: currentWeather)
        coordinator.send(action: MainScreenAction.Delegate.pushForecastView(city, .overlay, info))
        XCTAssertEqual(coordinator.childs.first?.type as? WeatherAppScreen, WeatherAppScreen.forecast)
        XCTAssertTrue(coordinator.childs.first is ForecastScreenCoordinator)
        XCTAssertTrue(coordinator.childs.first?.reducer is ForecastViewModel)

        XCTAssertTrue(parentCoordinator.pushedPages.contains(where: { $0 as? WeatherAppScreen == WeatherAppScreen.forecast }))
    }
    
    func testCoordinatorSendPopActionToParent() {
        let expectedWeather = CurrentWeather(id: 123,
                                            name: name,
                                            weather: [Weather(main: "Main",
                                                              icon: "")],
                                            main: Main(temp: 5,
                                                       tempMin: 2,
                                                       tempMax: 3),
                                            coord: Coordinates(lon: 10, lat: 10))
        let expectedInfo = WeatherCurrentInfo(currentWeather: expectedWeather)
        
        coordinator.send(action:  MainScreenAction.Delegate.popForecastViewWhenAdded(expectedInfo))
        if let action = reducer.state.action as? MainScreenAction,
           case let .addButtonPressed(info) = action {
            XCTAssertEqual(info, expectedInfo)
        } else {
            XCTFail("Expected popForecastViewWhenAdded action but got something else")
        }
            
        coordinator.send(action:  MainScreenAction.Delegate.popForecastViewWhenDeleted(expectedInfo))
        if let action = reducer.state.action as? MainScreenAction,
           case let .deleteButtonPressed(currentWeather) = action {
            XCTAssertEqual(currentWeather, expectedWeather)
        } else {
            XCTFail("Expected popForecastViewWhenAdded action but got something else")
        }
    }
}

class MainScreenViewModelTests: XCTestCase {
    var viewModel: MainScreenViewModel!
    var mockLocationService: MockLocationService!
    var mockStorageService: MockDataStorageService!
    var mockStorageManager: MockDataStorageManager!
    var mockNetworkManager: MockNetworkManager!
    var mockAuth: MockAuth!
    var coordinator: MockCoordinator!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockLocationService = MockLocationService()
        mockStorageService = MockDataStorageService()
        mockStorageManager = MockDataStorageManager(storageService: mockStorageService)
        mockNetworkManager = MockNetworkManager()
        mockAuth = MockAuth()
        coordinator = MockCoordinator(type: WeatherAppScreen.main)
        viewModel = MainScreenViewModel(coordinator: coordinator,
                                        locationService: mockLocationService,
                                        storageManager: mockStorageManager,
                                        networkService: mockNetworkManager,
                                        auth: mockAuth)
        coordinator.reducer = viewModel
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockStorageManager = nil
        mockNetworkManager = nil
        mockLocationService = nil
        cancellables = nil
        coordinator = nil
        mockAuth = nil
        super.tearDown()
    }
    
    func testWeatherSelected() {
        let currentWeather = CurrentWeather(id: 123,
                                            name: "Test",
                                            weather: [Weather(main: "Main",
                                                              icon: "")],
                                            main: Main(temp: 5,
                                                       tempMin: 2,
                                                       tempMax: 3),
                                            coord: Coordinates(lon: 10, lat: 10))
        let info = WeatherCurrentInfo(currentWeather: currentWeather)
        viewModel.send(MainScreenAction.weatherSelected(info))
        XCTAssertNotNil(coordinator.action)
        XCTAssertTrue(coordinator.action is MainScreenAction.Delegate)
        
        if let action = coordinator.action as? MainScreenAction.Delegate,
           case let .pushForecastView(receivedCity, receivedStyle, receivedWeatherInfo) = action {
            XCTAssertEqual(receivedCity.name, currentWeather.name)
            XCTAssertEqual(receivedStyle, WeatherDetailsViewStyle.overlayAdded)
            XCTAssertEqual(receivedWeatherInfo?.id, info.id)
        } else {
            XCTFail("Expected pushForecastView action but got something else")
        }
    }
        
        func testCitySelected() {
            let name = "SelectedCity"
            let city = City(name: name, lat: 42.0, lon: 44.0)
            let currentWeather = CurrentWeather(id: 123,
                                                name: name,
                                                weather: [Weather(main: "Main",
                                                                  icon: "")],
                                                main: Main(temp: 5,
                                                           tempMin: 2,
                                                           tempMax: 3),
                                                coord: Coordinates(lon: 10, lat: 10))
            viewModel.send(MainScreenAction.citySelected(city))
            XCTAssertNotNil(coordinator.action)
            XCTAssertTrue(coordinator.action is MainScreenAction.Delegate)
            
            if let action = coordinator.action as? MainScreenAction.Delegate,
               case let .pushForecastView(receivedCity, receivedStyle, receivedWeatherInfo) = action {
                
                XCTAssertEqual(receivedCity.name, currentWeather.name)
                XCTAssertEqual(receivedStyle, WeatherDetailsViewStyle.overlay)
                XCTAssertNil(receivedWeatherInfo?.id)
            } else {
                XCTFail("Expected pushForecastView action but got something else")
            }
        }
        
        func testDeleteButtonPressed() {
            let expectation = XCTestExpectation(description: "Successful search")
            let currentWeather = CurrentWeather(id: 123,
                                                name: "Test",
                                                weather: [Weather(main: "Main",
                                                                  icon: "")],
                                                main: Main(temp: 5,
                                                           tempMin: 2,
                                                           tempMax: 3),
                                                coord: Coordinates(lon: 10, lat: 10))
            let info = WeatherCurrentInfo(currentWeather: currentWeather)
            
            viewModel.state.weatherInfo = [info, info]
            viewModel.state.$weatherInfo
                .dropFirst()
                .sink { info in
                    XCTAssertEqual(info.count, 1)
                    expectation.fulfill()
                }
                .store(in: &cancellables)
            
            viewModel.send(MainScreenAction.deleteButtonPressed(info.currentWeather))
            wait(for: [expectation], timeout: 1.0)
        }
        
        func testAddButtonPressed() {
            let expectation = XCTestExpectation(description: "Successful search")
            let expectedID = "Test"
            let currentWeather = CurrentWeather(id: 123,
                                                name: name,
                                                weather: [Weather(main: "Main",
                                                                  icon: "")],
                                                main: Main(temp: 5,
                                                           tempMin: 2,
                                                           tempMax: 3),
                                                coord: Coordinates(lon: 10, lat: 10))
            let info = WeatherCurrentInfo(currentWeather: currentWeather)
            mockAuth.user = MockUser(uid: expectedID)
            
            viewModel.state.$weatherInfo
                .dropFirst()
                .sink { info in
                    XCTAssertEqual(info.count, 1)
                    XCTAssertEqual(self.mockStorageManager.addedItemID, expectedID)
                    expectation.fulfill()
                }
                .store(in: &cancellables)
            
            viewModel.send(MainScreenAction.addButtonPressed(info))
            wait(for: [expectation], timeout: 1.0)
        }
    
    func testSearchWithSuccessfulResponse() {
        let sampleCities = [City(name: "City1", lat: 10, lon: 10), City(name: "City2", lat: 20, lon: 20)]
        mockNetworkManager.stubbedResponse = sampleCities

        let expectation = XCTestExpectation(description: "Successful search")
        
        viewModel.state.$searchResult
            .dropFirst()
            .sink { cities in
                XCTAssertEqual(cities.count, sampleCities.count)
                XCTAssertTrue(self.mockNetworkManager.request is GeolocationsRequest)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.send(MainScreenAction.searchWith("query"))

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchStart() {
        mockNetworkManager.stubbedError = NetworkError.badURL

        let expectation = XCTestExpectation(description: "Search")
        
        viewModel.state.$searchState
            .dropFirst()
            .sink { state in
                XCTAssertEqual(state, SearchState.searching)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.send(MainScreenAction.searchWith("query"))

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchWithFailureResponse() {
        mockNetworkManager.stubbedError = NetworkError.badURL

        let expectation = XCTestExpectation(description: "Failed search")
        
        viewModel.state.$searchState
            .dropFirst()
            .sink { state in
                guard state != SearchState.searching else { return }

                XCTAssertEqual(state, SearchState.failed)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.send(MainScreenAction.searchWith("query"))

        wait(for: [expectation], timeout: 1.0)
    }

    func testSearchWithEmptyResponse() {
        mockNetworkManager.stubbedResponse = [City]()

        let expectation = XCTestExpectation(description: "Empty search results")
        
        viewModel.state.$searchState
            .dropFirst(1)
            .sink { state in
                guard state != SearchState.searching else { return }
                XCTAssertEqual(state, SearchState.empty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.send(MainScreenAction.searchWith("query"))

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchWeatherInfoSuccess() async {
        let id = "User"
        let currentWeather = CurrentWeather(id: 123,
                                           name: "Test",
                                           weather: [Weather(main: "Main",
                                                             icon: "")],
                                           main: Main(temp: 5,
                                                      tempMin: 2,
                                                      tempMax: 3),
                                           coord: Coordinates(lon: 10, lat: 10))
        mockNetworkManager.stubbedResponse = currentWeather
        mockAuth.user = MockUser(uid: id)
        mockStorageService.object = UserInfo(id: id)
        mockStorageService.info = StoreCoordinates()
        
        let expectation = XCTestExpectation(description: "Succeeded location fetch")

        viewModel.state.$fetchState
            .sink { state in
                switch state {
                case .none:
                    break
                case .succeed:
                    XCTAssertEqual(self.viewModel.state.weatherInfo.count, 1)
                    XCTAssertTrue(self.mockNetworkManager.request is CurrentWeatherRequest)
                    expectation.fulfill()
                default:
                    XCTFail("Expected success but failed")
                    expectation.fulfill()
                    break
                }
            }
            .store(in: &cancellables)

        viewModel.send(MainScreenAction.fetchWeatherInfo)

        await fulfillment(of: [expectation], timeout:  2.0)
    }
    
    func testFetchWeatherInfoFromStrageSuccess() async {
        let id = "User"
        let currentWeather = CurrentWeather(id: 123,
                                            name: "Test",
                                            weather: [Weather(main: "Main",
                                                              icon: "")],
                                            main: Main(temp: 5,
                                                       tempMin: 2,
                                                       tempMax: 3),
                                            coord: Coordinates(lon: 10, lat: 10))
        mockNetworkManager.stubbedResponse = currentWeather
        mockAuth.user = MockUser(uid: id)
        mockStorageService.object = UserInfo(id: id)
        mockStorageService.info = StoreCoordinates()
        mockStorageManager.coordinates = [Coordinates(lon: 10, lat: 10),
                                          Coordinates(lon: 10, lat: 10)]
        
        let expectation = XCTestExpectation(description: "Succeeded location fetch")
        
        viewModel.state.$weatherInfo
            .dropFirst(2)
            .sink { info in
                XCTAssertEqual(info.count, 3)
                XCTAssertTrue(self.mockNetworkManager.request is CurrentWeatherRequest)
                expectation.fulfill()
                
            }
            .store(in: &cancellables)
        
        viewModel.send(MainScreenAction.fetchWeatherInfo)
        await fulfillment(of: [expectation], timeout:  2.0)
    }
    
    func testFetchWeatherInfoLocationFailure() async {
        mockLocationService.shouldFail = true
        
        let expectation = XCTestExpectation(description: "Failed location fetch")
        viewModel.state.$fetchState
            .sink { state in
                switch state {
                case .none:
                    break
                case .succeed:
                   XCTFail("Expected failure when fetching weather for current location")
                case .failed(let error):
                    XCTAssertEqual(error, .locationFetchFail)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.send(MainScreenAction.fetchWeatherInfo)

        await fulfillment(of: [expectation], timeout:  1.0)
    }
    
    func testFetchWeatherInfoWithFailure() async {
        mockNetworkManager.stubbedError = NetworkError.badURL
        
        let expectation = XCTestExpectation(description: "Failed location fetch")
        viewModel.state.$fetchState
            .sink { state in
                switch state {
                case .none:
                    break
                case .succeed:
                   XCTFail("Expected failure when fetching weather for current location")
                case .failed(let error):
                    XCTAssertEqual(error, .weatherFetchFail)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.send(MainScreenAction.fetchWeatherInfo)
        await fulfillment(of: [expectation], timeout:  1.0)
    }
    
    func testLocationStatusUpdate() async {
        let expectation = XCTestExpectation(description: "Location status should be updated")
        let expectedStatus: LocationAuthorizationStatus = .authorized
        
        viewModel.state.$locationStatus
            .dropFirst(1)
            .sink { status in
                XCTAssertEqual(status, expectedStatus)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        mockLocationService.change(status: expectedStatus)
        
        await fulfillment(of: [expectation], timeout:  1.0)
    }
    
    func testWeatherCardViewPresentationInfo() {
        let coordinates = Coordinates(lon: 10.1093, lat: 20.2938)
        let weatherDetails = Main(temp: 15.7864, tempMin: 10.0, tempMax: 20.0)
        let weather = [Weather(main: "Cloudy", icon: "")]
        let name = "London"
        let currentWeather1 = CurrentWeather(id: 10,
                                            name: name,
                                            weather: weather,
                                            main: weatherDetails,
                                            coord: coordinates)
        let weatherInfo = WeatherCurrentInfo(currentWeather: currentWeather1)
        
        let viewInfo = viewModel.weatherCardViewPresentationInfo(weatherInfo: weatherInfo)
        
        // Validation
        XCTAssertEqual(viewInfo.myLocation, name)
        XCTAssertEqual(viewInfo.location, name)
        XCTAssertEqual(viewInfo.temperature, "16°")
        XCTAssertEqual(viewInfo.description, LocalizedText.cloudy)
        XCTAssertEqual(viewInfo.tempRangeDescription, "\(LocalizedText.high) :20° \(LocalizedText.low) :10°")
        
        let currentWeather2 = CurrentWeather(id: 10,
                                            name: name,
                                            weather: [],
                                            main: weatherDetails,
                                            coord: coordinates)
        let weatherInfo2 = WeatherCurrentInfo(currentWeather: currentWeather2, unit: .farenheit,
                                              isMyLocation: true)
        let viewInfo2 = viewModel.weatherCardViewPresentationInfo(weatherInfo: weatherInfo2)

        XCTAssertEqual(viewInfo2.myLocation, LocalizedText.myLocation)
        XCTAssertEqual(viewInfo2.location, name)
        XCTAssertEqual(viewInfo2.temperature, "16F")
        XCTAssertEqual(viewInfo2.description, "")
        XCTAssertEqual(viewInfo2.tempRangeDescription, "\(LocalizedText.high) :20F \(LocalizedText.low) :10F")
    }
}

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

class MainScreenViewModelTests: XCTestCase {
    var viewModel: MainScreenViewModel!
    var mockDependencyManager: MockDependencyManager!
    var mockLocationService: MockLocationService!
    var mockStorageService: MockDataStorageService!
    var mockStorageManager: MockDataStorageManager!
    var mockNetworkManager: MockNetworkManager!
    var coordinator: MockCoordinator!
    var mockAuth: MockAuth!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockLocationService = MockLocationService()
        mockStorageService = MockDataStorageService()
        mockStorageManager = MockDataStorageManager(storageService: mockStorageService)
        mockNetworkManager = MockNetworkManager()
        mockAuth = MockAuth()
        mockDependencyManager = MockDependencyManager(auth: mockAuth,
                                                      storageManager: mockStorageManager,
                                                      networkService: mockNetworkManager,
                                                      locationService: mockLocationService)
        coordinator = MockCoordinator(dependenciesManager: mockDependencyManager)

        viewModel = MainScreenViewModel(coordinator: coordinator)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockDependencyManager = nil
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
        viewModel.weatherSelected(with: info)
        XCTAssertEqual(coordinator.selectedCity?.name, currentWeather.name)
        XCTAssertEqual(coordinator.selectedCity?.lat, currentWeather.coord.lat)
        XCTAssertEqual(coordinator.selectedCity?.lon, currentWeather.coord.lon)
        XCTAssertEqual(coordinator.style, WeatherDetailsViewStyle.overlayAdded)
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
            let info = WeatherCurrentInfo(currentWeather: currentWeather)
            viewModel.citySelected(city)
            
            XCTAssertEqual(coordinator.selectedCity?.name, city.name)
            XCTAssertEqual(coordinator.selectedCity?.lat, city.lat)
            XCTAssertEqual(coordinator.selectedCity?.lon, city.lon)
            XCTAssertEqual(coordinator.style, WeatherDetailsViewStyle.overlay)
            
            viewModel.weatherInfo = [info]
            viewModel.citySelected(city)
            XCTAssertEqual(coordinator.style, WeatherDetailsViewStyle.overlayAdded)
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
            
            viewModel.weatherInfo = [info, info]
            
            viewModel.$weatherInfo
                .dropFirst()
                .sink { info in
                    XCTAssertEqual(info.count, 1)
                    expectation.fulfill()
                }
                .store(in: &cancellables)
            
            viewModel.deleteButtonPressed(info: info.currentWeather)
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
            
            viewModel.$weatherInfo
                .dropFirst()
                .sink { info in
                    XCTAssertEqual(info.count, 1)
                    XCTAssertEqual(self.mockStorageManager.addedItemID, expectedID)

                    expectation.fulfill()
                }
                .store(in: &cancellables)
            
            viewModel.addButtonPressed(info: info)
            wait(for: [expectation], timeout: 1.0)
        }
    
    func testGetCurrentLocationInfoSuccess() async {
        do {
            let location = try await viewModel.getCurrentLocationInfo()
            XCTAssertEqual(location.coordinate.latitude, 50.0)
            XCTAssertEqual(location.coordinate.longitude, -50.0)
        } catch {
            XCTFail("Expected successful location fetch, but threw an error: \(error)")
        }
    }
    
    func testGetCurrentLocationInfoFailure() async {
        mockLocationService.shouldFail = true 

        do {
            let _ = try await viewModel.getCurrentLocationInfo()
            XCTFail("Expected an error, but location fetch was successful")
        } catch {
            XCTAssertEqual(error as? AppError, AppError.locationFetchFail)
        }
    }
    
    func testSearchWithSuccessfulResponse() {
        let sampleCities = [City(name: "City1", lat: 10, lon: 10), City(name: "City2", lat: 20, lon: 20)]
        mockNetworkManager.stubbedResponse = sampleCities

        let expectation = XCTestExpectation(description: "Successful search")
        
        viewModel.$searchResult
            .dropFirst()
            .sink { cities in
                XCTAssertEqual(cities.count, sampleCities.count)
                XCTAssertTrue(self.mockNetworkManager.request is GeolocationsRequest)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.searchWith(query: "query")

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchStart() {
        mockNetworkManager.stubbedError = NetworkError.badURL

        let expectation = XCTestExpectation(description: "Search")
        
        viewModel.$searchState
            .dropFirst()
            .sink { state in
                XCTAssertEqual(state, SearchState.searching)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.searchWith(query: "query")

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchWithFailureResponse() {
        mockNetworkManager.stubbedError = NetworkError.badURL

        let expectation = XCTestExpectation(description: "Failed search")
        
        viewModel.$searchState
            .dropFirst()
            .sink { state in
                guard state != SearchState.searching else { return }

                XCTAssertEqual(state, SearchState.failed)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.searchWith(query: "query")

        wait(for: [expectation], timeout: 1.0)
    }

    func testSearchWithEmptyResponse() {
        mockNetworkManager.stubbedResponse = [City]()

        let expectation = XCTestExpectation(description: "Empty search results")
        
        viewModel.$searchState
            .dropFirst(1)
            .sink { state in
                guard state != SearchState.searching else { return }
                XCTAssertEqual(state, SearchState.empty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.searchWith(query: "query")

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

        viewModel.$fetchState
            .sink { state in
                switch state {
                case .none:
                    break
                case .succeed:
                    XCTAssertEqual(self.viewModel.weatherInfo.count, 1)
                    XCTAssertTrue(self.mockNetworkManager.request is CurrentWeatherRequest)
                    expectation.fulfill()
                default:
                    XCTFail("Expected success but failed")
                    expectation.fulfill()
                    break
                }
            }
            .store(in: &cancellables)

        await viewModel.fetchWeatherInfo()

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
        
        viewModel.$weatherInfo
            .dropFirst(2)
            .sink { info in
                XCTAssertEqual(info.count, 3)
                XCTAssertTrue(self.mockNetworkManager.request is CurrentWeatherRequest)
                expectation.fulfill()
                
            }
            .store(in: &cancellables)
        
        await viewModel.fetchWeatherInfo()
        await fulfillment(of: [expectation], timeout:  2.0)
    }
    
    func testFetchWeatherInfoLocationFailure() async {
        mockLocationService.shouldFail = true
        
        let expectation = XCTestExpectation(description: "Failed location fetch")
        viewModel.$fetchState
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

        await viewModel.fetchWeatherInfo()

        await fulfillment(of: [expectation], timeout:  1.0)
    }
    
    func testFetchWeatherInfoWithFailure() async {
        mockNetworkManager.stubbedError = NetworkError.badURL
        
        let expectation = XCTestExpectation(description: "Failed location fetch")
        viewModel.$fetchState
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

        await viewModel.fetchWeatherInfo()

        await fulfillment(of: [expectation], timeout:  1.0)
    }
    
    func testLocationStatusUpdate() {
        let expectation = XCTestExpectation(description: "Location status should be updated")
        let expectedStatus: LocationAuthorizationStatus = .authorized
        
        viewModel.$locationStatus
            .dropFirst(2)
            .sink { status in
                XCTAssertEqual(status, expectedStatus)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        mockLocationService.change(status: expectedStatus)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
//    func testWeatherInfoAppendAndStorageUpdate() {
//        let latitude = 10.0
//        let longitude = 20.0
//        let index = viewModel.weatherInfo.count
//        mockAuth.user = MockUser(uid: "Test")
//
//        let expectation = XCTestExpectation(description: "Weather info should be appended and stored")
//        let testWeatherInfo = WeatherCurrentInfo(id: UUID(),
//                                                 currentWeather: CurrentWeather(id: 1,
//                                                                                name: "",
//                                                                                weather: [Weather(main: "",
//                                                                                                  icon: "")],
//                                                                                main: Main(temp: 10,
//                                                                                           tempMin: 20,
//                                                                                           tempMax: 30),
//                                                                                coord: Coordinates(lon: longitude,
//                                                                                                   lat: latitude)),
//                                                 unit: .celsius,
//                                                 isMyLocation: false)
//        
//        viewModel.$weatherInfo
//            .dropFirst()
//            .sink { [weak self] weatherInfoArray in
//                XCTAssertEqual((self?.mockStorageManager.info as? StoreCoordinates)?.index, index)
//                XCTAssertEqual((self?.mockStorageManager.info as? StoreCoordinates)?.latitude, latitude)
//                XCTAssertEqual((self?.mockStorageManager.info as? StoreCoordinates)?.longitude, longitude)
//                XCTAssertEqual(self?.mockStorageManager.object?.id, self?.mockAuth.currentUser?.uid)
//                expectation.fulfill()
//            }
//            .store(in: &cancellables)
//        
//        viewModel.addedWaetherInfo.send(testWeatherInfo)
//        
//        wait(for: [expectation], timeout: 5.0)
//    }
    
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

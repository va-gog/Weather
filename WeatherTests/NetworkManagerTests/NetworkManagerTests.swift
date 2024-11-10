//
//  NetworkManagerTests.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

import XCTest
import Combine
@testable import Weather

struct MockNetworkRequest: NetworkRequest {
    var path: String
}

final class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkServiceProvider!
    var mockSessionManager: MockURLSessionManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockSessionManager = MockURLSessionManager()
        networkManager = NetworkServiceProvider(sessionManager: mockSessionManager)
        cancellables = []
    }

    override func tearDown() {
        networkManager = nil
        mockSessionManager = nil
        cancellables = nil
        super.tearDown()
    }

    func testDownloadJSON_WhenBadUrl() {
        let expectation = self.expectation(description: "Download JSON Failure")

        networkManager.requestJSON(MockNetworkRequest(path: ""))
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error,NetworkError.badURL)
                }
                expectation.fulfill()
            }, receiveValue: { data in
                XCTFail("Unexpected data received: \(data)")
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDownloadJSON_WhenUrlSessionFaialed() {
        let path = "https://raw.githubusercontent.com/downapp/sample/main/sample.json"
        mockSessionManager.data = nil
        mockSessionManager.error = NetworkError.requestFailed
        
        let expectation = self.expectation(description: "Download JSON Failure")

        networkManager.requestJSON(MockNetworkRequest(path: path))
            .sink(receiveCompletion: { completion in
                if case .failure(.unknown(let error)) = completion {
                    XCTAssertEqual(error as! NetworkError, NetworkError.requestFailed)
                }
                expectation.fulfill()
            }, receiveValue: { data in
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDownloadJSON_Success() {
        let path = "https://raw.githubusercontent.com/downapp/sample/main/sample.json"
        let jsonData = """
           {
               "userId": 1,
               "id": 1,
               "title": "delectus aut autem",
               "completed": false
           }
           """.data(using: .utf8)!
        mockSessionManager.data = jsonData
        mockSessionManager.error = nil
        
        let expectation = self.expectation(description: "Download JSON")
        
        networkManager.requestJSON(MockNetworkRequest(path: path)).sink { completion in
            if case .failure(let error) = completion {
                XCTFail("Error: \(error)")
            }
            expectation.fulfill()
        } receiveValue: { data in
            XCTAssertNotNil(data, "No data was downloaded.")
            expectation.fulfill()
        }.store(in: &cancellables)
        
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchAndDecodeSuccess() {
        struct Todo: Decodable {
            let userId: Int
            let id: Int
            let title: String
            let completed: Bool
        }
        
        let path = "https://jsonplaceholder.typicode.com/todos/1"
        let jsonData = """
                {
                    "userId": 1,
                    "id": 1,
                    "title": "delectus aut autem",
                    "completed": false
                }
                """.data(using: .utf8)!
                mockSessionManager.data = jsonData
                mockSessionManager.error = nil
        
        let expectation = self.expectation(description: "Fetch and Decode JSON")
        
        networkManager.requestData(MockNetworkRequest(path: path), as: Todo.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Error: \(error)")
                }
                expectation.fulfill()

            }, receiveValue: { todo in
                XCTAssertEqual(todo.id, 1)
                XCTAssertEqual(todo.userId, 1)
                XCTAssertEqual(todo.title, "delectus aut autem")
                XCTAssertFalse(todo.completed)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFetchAndDecodeFailure() {
        struct Todo: Decodable {
            let userId: Int
            let id: Int
            let title: String
            let completed: Bool
        }
        
        let path = "https://jsonplaceholder.typicode.com/invalid-endpoint"
        mockSessionManager.error = NetworkError.unknown(URLError(.badServerResponse))
        
        let expectation = self.expectation(description: "Fetch and Decode JSON Failure")
        
        networkManager.requestData(MockNetworkRequest(path: path), as: Todo.self)
            .sink(receiveCompletion: { completion in
                if case .failure(_) = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { todo in
                XCTFail("Unexpected data received: \(todo)")
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}

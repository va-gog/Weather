//
//  MockNetworkManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

@testable import Weather
import Foundation
import Combine

final class MockNetworkManager: NetworkServiceProtocol {
    var stubbedResponse: Decodable?
    var stubbedData: Data?
    var stubbedError: NetworkError?
    var request: NetworkRequest?
    
    func requestJSON(_ request: NetworkRequest) -> AnyPublisher<Data, NetworkError> {
        self.request = request
        if let error = stubbedError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just(stubbedData ?? Data()).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
    }
    
    func requestData<T: Decodable>(_ request: NetworkRequest, as type: T.Type) -> AnyPublisher<T, NetworkError> {
        self.request = request
        if let error = stubbedError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        if let response = stubbedResponse as? T {
            return Just(response).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
        }
        fatalError("Fetch and Decode stub not set properly.")
    }
}

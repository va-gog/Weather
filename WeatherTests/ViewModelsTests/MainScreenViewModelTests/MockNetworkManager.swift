//
//  MockNetworkManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

@testable import Weather
import Foundation
import Combine

final class MockNetworkManager {
    var stubbedResponse: Decodable?
    var stubbedData: Data?
    var stubbedError: NetworkError?
//    
//    func downloadJSON(from urlString: String) -> AnyPublisher<Data, NetworkError> {
//        if let error = stubbedError {
//            return Fail(error: error).eraseToAnyPublisher()
//        }
//        return Just(stubbedData ?? Data()).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
//    }
//    
//    func fetchAndDecode<T: Decodable>(from urlString: String, as type: T.Type) -> AnyPublisher<T, NetworkError> where T: Decodable {
//        if let error = stubbedError {
//            return Fail(error: error).eraseToAnyPublisher()
//        }
//        if let response = stubbedResponse as? T {
//            return Just(response).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
//        }
//        fatalError("Fetch and Decode stub not set properly.")
//    }
}

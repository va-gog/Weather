//
//  NetworkServiceProvider.swift
//  Weather
//
//  Created by Gohar Vardanyan on 23.10.24.
//

import Foundation
import Combine

struct NetworkServiceProvider: NetworkServiceProtocol {    
    private var sessionManager: URLSessionManagerProtocol
    
    init(sessionManager: URLSessionManagerProtocol = URLSessionManager()) {
        self.sessionManager = sessionManager
    }
    
    func requestJSON(_ request: NetworkRequest) -> AnyPublisher<Data, NetworkError> {
        guard let url = URL(string: request.path) else {
            return Fail(error: NetworkError.badURL).eraseToAnyPublisher()
        }
        
        return sessionManager.dataTaskPublisher(url: url)
            .mapError({ error in NetworkError.unknown(error)})
            .eraseToAnyPublisher()
    }
    
    func requestData<T: Decodable>(_ request: NetworkRequest, as type: T.Type) -> AnyPublisher<T, NetworkError> {
        return requestJSON(request)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                NetworkError.networkError(from: error)
            }
            .eraseToAnyPublisher()
    }
}

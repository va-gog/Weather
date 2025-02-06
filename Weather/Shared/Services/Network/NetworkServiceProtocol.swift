//
//  NetworkServiceProtocol.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func requestJSON(_ request: NetworkRequest) -> AnyPublisher<Data, NetworkError>
    func requestData<T: Decodable>(_ request: NetworkRequest, as type: T.Type) -> AnyPublisher<T, NetworkError>
}

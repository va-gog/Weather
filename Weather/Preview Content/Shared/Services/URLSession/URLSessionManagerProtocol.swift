//
//  URLSessionManagerProtocol.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Foundation
import Combine

protocol URLSessionManagerProtocol {
    func dataTaskPublisher(url: URL) -> AnyPublisher<Data, Error>
    func dataFrom(url: URL) async throws -> (Data, URLResponse)
}

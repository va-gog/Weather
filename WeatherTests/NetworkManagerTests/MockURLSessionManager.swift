//
//  MockURLSessionManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

import Foundation
import Combine
@testable import Weather

final class MockURLSessionManager: URLSessionManagerProtocol {
    var data: Data?
    var error: NetworkError?
    let subject = CurrentValueSubject<Data, Error>(Data())

    func dataTaskPublisher(url: URL) -> AnyPublisher<Data, Error> {
            if let error = self.error {
                self.subject.send(completion: .failure(error))
            } else {
                self.subject.send(self.data ?? Data())
            }
            
        return subject.eraseToAnyPublisher()
    }
    
    func dataFrom(url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        } else {
            return (data ?? Data(), URLResponse())
        }
    }

}

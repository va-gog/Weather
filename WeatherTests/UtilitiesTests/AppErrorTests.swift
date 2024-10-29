//
//  AppErrorTests.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

import XCTest
@testable import Weather

class AppErrorTests: XCTestCase {

    func testErrorEquality() {
        XCTAssertEqual(AppError.locationFetchFail, AppError.locationFetchFail)
        XCTAssertEqual(AppError.weatherFetchFail, AppError.weatherFetchFail)
        XCTAssertNotEqual(AppError.weatherFetchFail, AppError.locationFetchFail)
        
        let underlyingError = NSError(domain: "TestError", code: 0, userInfo: nil)
        XCTAssertEqual(AppError.failure(underlyingError), AppError.failure(underlyingError))
        XCTAssertNotEqual(AppError.failure(underlyingError), AppError.locationFetchFail)
    }
    
    func testConvertToFetchError() {
        XCTAssertEqual(AppError.convertToFetchError(error: LocationError.noLocationAvailable), AppError.locationFetchFail)
        
        let randomError = NSError(domain: "RandomError", code: 404, userInfo: nil)
        XCTAssertEqual(AppError.convertToFetchError(error: randomError), AppError.failure(randomError))
        
        XCTAssertEqual(AppError.convertToFetchError(error: AppError.weatherFetchFail), AppError.weatherFetchFail)
    }
    
}

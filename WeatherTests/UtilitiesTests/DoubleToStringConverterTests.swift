//
//  DoubleToStringConverterTests.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

import XCTest
@testable import Weather 

class DoubleToStringConverterTests: XCTestCase {
    var converter: DoubleToStringConverter!
    
    override func setUp() {
        super.setUp()
        converter = DoubleToStringConverter()
    }
    
    override func tearDown() {
        converter = nil
        super.tearDown()
    }
    
    func testFormatDoubleZero() {
        let result = converter.formatDoubleToString(value: 0.0)
        XCTAssertEqual(result, "0", "Formatting zero with zero decimal places should return '0'.")
    }
    
    func testFormatDoublePositiveWithDecimalPlaces() {
        let result = converter.formatDoubleToString(value: 123.456, decimalPlaces: 2)
        XCTAssertEqual(result, "123,46", "Formatting a positive number with two decimal places should round and format correctly.")
    }
    
    func testFormatDoubleNegativeWithDecimalPlaces() {
        let result = converter.formatDoubleToString(value: -123.456, decimalPlaces: 3)
        XCTAssertEqual(result, "-123,456", "Formatting a negative number with three decimal places should format correctly.")
    }
    
    func testFormatExcessiveDecimalPlaces() {
        let result = converter.formatDoubleToString(value: 1.123456789, decimalPlaces: 5)
        XCTAssertEqual(result, "1,12346", "Formatting with excessive decimal places should be rounded correctly.")
    }
    
    func testFormatWithoutDecimalPlaces() {
        let result = converter.formatDoubleToString(value: 1.99999)
        XCTAssertEqual(result, "2", "Formatting without specifying decimal places should round to nearest integer.")
    }
}


//
//  DateToStringConverterTests.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

import XCTest
@testable import Weather

class DateToStringConverterTests: XCTestCase {
    
    var dateToStringConverter: DateToStringConverter!
    
    override func setUp() {
        super.setUp()
        dateToStringConverter = DateToStringConverter()
    }
    
    override func tearDown() {
        dateToStringConverter = nil
        super.tearDown()
    }
    
    func testConvertHourWithNow() {
        let date = Date()
        
        let result = dateToStringConverter.convertHour(date: date)
        XCTAssertEqual(result, "now", "The convertHour method should return 'now' for the current time.")
    }
    
    func testConvertHourWithHoursAgo() {
        let date = Calendar.current.date(byAdding: .hour, value: 3, to: Date())!
        
        let result = dateToStringConverter.convertHour(date: date)
        let expectedResult = DateFormatter.localizedString(from: date,
                                                           dateStyle: .none,
                                                           timeStyle: .short)
            .components(separatedBy: ":")[0] 
        XCTAssertEqual(result, expectedResult, "The convertHour method should return the exact hour for a past date.")
    }
    
    func testConvertDayToday() {
        let date = Date()
        
        let result = dateToStringConverter.convertDay(date: date)
        XCTAssertEqual(result, "Today", "The convertDay method should return 'Today' for the current day.")
    }
    
    func testConvertDayYesterday() {
        let date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        let result = dateToStringConverter.convertDay(date: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeZone = TimeZone.current
        let expectedResult = dateFormatter.string(from: date)
        XCTAssertEqual(result, expectedResult, "The convertDay method should return the name of the day for past dates.")
    }
}

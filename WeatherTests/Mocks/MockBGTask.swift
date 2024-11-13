//
//  MockBGTask.swift
//  Weather
//
//  Created by Gohar Vardanyan on 13.11.24.
//

@testable import Weather

struct MockBGTask: BGTaskInterface {
    func setTaskCompleted(success: Bool) {
        true
    }
    
    
}

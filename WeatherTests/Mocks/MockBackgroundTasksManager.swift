//
//  MockBackgroundTasksManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

@testable import Weather
import SwiftUI

final class MockBackgroundTasksManager: BackgroundTasksManagerInterface {
    var backgroundTaskSubmitted = false
    var backgroundRequestSetuped = false
    
    func setupBackgroundRequest(with identifier: String, completion:  @escaping (BGTaskInterface) -> Void) {
        backgroundRequestSetuped = true
    }
    
    func submitBackgroundTasks(with identifier: String) {
        backgroundTaskSubmitted = true
    }

}

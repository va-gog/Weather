//
//  MockBackgroundTasksManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 11.11.24.
//

@testable import Weather
import SwiftUI

final class MockBackgroundTasksManager: BackgroundTasksManagerInterface {
    var appRefreshTaskScheduled = false
    var setupBackgroundRequest = false

    func scheduleAppRefreshTask(identifier: String) {
        appRefreshTaskScheduled = true
    }
    
    func setupBackgroundRequest(phase: ScenePhase, identifier: String) {
        setupBackgroundRequest = true
    }
}

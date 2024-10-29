//
//  BackgroundTasksManagerInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

import SwiftUI

protocol BackgroundTasksManagerInterface {
    func scheduleAppRefreshTask(identifier: String)
    func setupBackgroundRequest(phase: ScenePhase, identifier: String)
}

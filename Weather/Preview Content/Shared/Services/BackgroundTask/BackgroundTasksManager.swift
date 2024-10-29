//
//  BackgroundTasksManager.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

import Foundation
import BackgroundTasks
import SwiftUI

struct BackgroundTasksManager: BackgroundTasksManagerInterface {
    
    func scheduleAppRefreshTask(identifier: String) {
        let request = BGAppRefreshTaskRequest(
            identifier: identifier
        )
        do {
            try BGTaskScheduler.shared.submit(request)
            print("[BGTaskScheduler] submitted task with id: \(request.identifier)")
        } catch let error {
            print("[BGTaskScheduler] error:", error)
        }
    }
    
    func setupBackgroundRequest(phase: ScenePhase, identifier: String) {
        switch phase {
        case .active: break
        case .inactive: break
        case .background:
            let request = BGAppRefreshTaskRequest(identifier: identifier)
            request.earliestBeginDate = Calendar.current.date(byAdding: .second, value: 30, to: Date())
            do {
                try BGTaskScheduler.shared.submit(request)
            } catch(let error) {
                print("Scheduling Error \(error.localizedDescription)")
            }
        @unknown default: break
        }
    }
    
}

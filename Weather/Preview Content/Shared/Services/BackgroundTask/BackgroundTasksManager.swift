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
    
    func setupBackgroundRequest(with identifier: String, completion:  @escaping (BGTaskInterface) -> Void) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { task in
            task.expirationHandler = {
                task.setTaskCompleted(success: true)
            }
            Task {
                completion(task)
            }
        }
    }
    
    func submitBackgroundTasks(with identifier: String) {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}

//
//  BackgroundTasksManagerInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

import BackgroundTasks

protocol BackgroundTasksManagerInterface {
    func setupBackgroundRequest(with identifier: String, completion:  @escaping (BGTaskInterface) -> Void)
    func submitBackgroundTasks(with identifier: String)
}

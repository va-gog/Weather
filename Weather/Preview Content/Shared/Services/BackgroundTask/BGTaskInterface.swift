//
//  BGTaskInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 13.11.24.
//

import BackgroundTasks

protocol BGTaskInterface {
    func setTaskCompleted(success: Bool)
}

extension BGTask: BGTaskInterface { }

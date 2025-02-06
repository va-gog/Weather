//
//  AppDelegate.swift
//  Weather
//
//  Created by Gohar Vardanyan on 27.10.24.
//

import UIKit
import FirebaseCore

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        return true
    }

}

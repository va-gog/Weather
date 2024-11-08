//
//  AppLaunchViewModel.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI
import Combine

final class AppLaunchViewModel: ObservableObject {
    @ObservedObject var coordinator: Coordinator
    @Published var path: NavigationPath = NavigationPath()
    private var dependencies: CoordinatorScreenDependenciesInterface
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private var cancelable: AnyCancellable?
    private var isAuthenticated = false
    
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
        self.dependencies = coordinator.dependenciesManager.coordinatorScreenDependencies()
        
    }

    func registerAuthStateHandler() {
        authStateHandler = dependencies.auth.addStateDidChangeListener(completion: { [weak self] auth, user in
            guard let self else { return }
            if user == nil {
                self.push(AppPages.login)
                self.authStateHandler = nil
            } else {

                switch dependencies.locationService.statusSubject.value {
                case .notDetermined:
                    cancelable = dependencies.locationService.statusSubject
                        .dropFirst()
                        .sink { [weak self] status in
                            status == .authorized ? self?.push(AppPages.main) : self?.push(AppPages.locationAccess)
                            self?.authStateHandler = nil
                    }
                    dependencies.locationService.requestWhenInUseAuthorization()
                case .authorized:
                    push(AppPages.main)
                    self.authStateHandler = nil
                case .denied:
                    push(AppPages.locationAccess)
                    self.authStateHandler = nil
                }
            }
        })
    }
    
    private func push(_ page: AppPages) {
        self.coordinator.pop(PopAction.authenticated)
        self.coordinator.push(page: page)
        
    }

}

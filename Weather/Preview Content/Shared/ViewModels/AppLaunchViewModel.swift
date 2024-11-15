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
    @Published var coordinator: CoordinatorInterface
    
    private var dependencies: AppLaunchScreenDependenciesInterface
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private var cancelable: AnyCancellable?
    
    init(coordinator: CoordinatorInterface) {
        self.coordinator = coordinator
        self.dependencies = coordinator.dependenciesManager.createAppLaunchScreenDependencies()
    }

    func registerAuthStateHandler() {
        authStateHandler = dependencies.auth.addStateDidChangeListener(completion: { [weak self] auth, user in
            guard let self else { return }
            if user == nil {
                self.coordinator.push(page: .authentication)
                self.authStateHandler = nil
            } else {
                switch dependencies.locationService.statusSubject.value {
                case .notDetermined:
                    cancelable = dependencies.locationService.statusSubject
                        .dropFirst()
                        .sink { [weak self] status in
                            status == .authorized ? self?.coordinator.push(page: .main) : self?.coordinator.push(page: .locationAccess)
                                self?.authStateHandler = nil
                    }
                    dependencies.locationService.requestWhenInUseAuthorization()
                case .authorized:
                    coordinator.push(page: .main)
                    authStateHandler = nil
                case .denied:
                    coordinator.push(page: .locationAccess)
                    authStateHandler = nil
                }
            }
        })
    }
}

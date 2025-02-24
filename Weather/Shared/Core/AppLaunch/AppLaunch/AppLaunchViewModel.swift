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
import CoreLocation

final class AppLaunchViewModel: ObservableObject {
    
    @Published var coordinator: any CoordinatorInterface
    
    @Dependency private var locationService: LocationServiceInterface
    @Dependency private var auth: AuthInterface
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private var cancelable: AnyCancellable?
    
    init(coordinator: any CoordinatorInterface, locationService: LocationServiceInterface? = nil, auth: AuthInterface? = nil) {
        self.coordinator = coordinator
        registerDependencies()
        injectMocks(locationService, auth)
    }
    
    private func registerDependencies() {
        DependencyManager.register(LocationManagerInterface.self, factory: CLLocationManager())
        DependencyManager.register(LocationServiceInterface.self, factory: LocationService())
        DependencyManager.register(StorageInterface.self, factory: RealmWrapper())
        DependencyManager.register(StorageServiceInterface.self, factory: StorageService())
        DependencyManager.register(StorageManagerInterface.self, factory: StorageManager())
        DependencyManager.register(AuthInterface.self, factory: AuthWrapper())
        DependencyManager.register(URLSessionManagerProtocol.self, factory: URLSessionManager())
        DependencyManager.register(NetworkServiceProtocol.self, factory: NetworkServiceProvider())
        DependencyManager.register(BackgroundTasksManagerInterface.self, factory: BackgroundTasksManager())
        DependencyManager.register(UserNotificationsFactoryInterface.self, factory: UserNotificationFactory())
        DependencyManager.register(KeychainInterface.self, factory: KeychainAdapter())
        DependencyManager.register(KeychainManagerInterface.self, factory: KeychainManager())
        DependencyManager.register(WeatherInfoToPresentationInfoConverterInterface.self, factory: WeatherInfoToPresentationInfoConverter())
    }

    func registerAuthStateHandler() {
        authStateHandler = auth.addStateDidChangeListener(completion: { [weak self] auth, user in
            guard let self else { return }
            if user == nil {
                self.coordinator.push(WeatherAppScreen.authentication)
                self.authStateHandler = nil
            } else {
                switch locationService.statusSubject.value {
                case .notDetermined:
                    cancelable = locationService.statusSubject
                        .dropFirst()
                        .sink { [weak self] status in
                            let screen = status == .authorized ? WeatherAppScreen.main : WeatherAppScreen.locationAccess
                            self?.coordinator.push(screen)
                            self?.authStateHandler = nil
                    }
                    locationService.requestWhenInUseAuthorization()
                case .authorized:
                    coordinator.push(WeatherAppScreen.main)
                    authStateHandler = nil
                case .denied:
                    coordinator.push(WeatherAppScreen.locationAccess)
                    authStateHandler = nil
                }
            }
        })
    }
    
    private func injectMocks(_ locationService: LocationServiceInterface? = nil, _ auth: AuthInterface? = nil) {
        if let locationService {
            self.locationService = locationService
        }
        if let auth {
            self.auth = auth
        }
    }
}

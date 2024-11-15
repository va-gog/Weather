//
//  Coordinator.swift
//  Weather
//
//  Created by Gohar Vardanyan on 08.11.24.
//

import SwiftUI

final class AppLaunchScreenCoordinator: CoordinatorInterface, ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    
    var type: AppPages = .launch
    var parent: CoordinatorInterface?
    var childs: [CoordinatorInterface] = []
    var dependenciesManager: DependencyManagerInterface
    
    
    init(dependenciesManager: DependencyManagerInterface) {
        self.dependenciesManager = dependenciesManager
    }
    
    func push(page: AppPages) {
        switch page {
        case .locationAccess:
            childs.removeAll()
            childs.append(LocationPermitionScreenCoordinator(dependenciesManager: dependenciesManager))
            var newPath = NavigationPath()
            newPath.append(AppPages.locationAccess)
            path = newPath
        case .main:
            let coordinator = MainScreenCoordinator(parent: self,
                                                    dependenciesManager: dependenciesManager)
            let viewModel = MainScreenViewModel(coordinator: coordinator)
            coordinator.mainScreenViewModel = viewModel
            childs.removeAll()
            childs.append(coordinator)
            var newPath = NavigationPath()
            newPath.append(AppPages.main)
            path = newPath
        case .authentication:
            childs.removeAll()
            childs.append(AuthenticationViewCoordinator(dependenciesManager: dependenciesManager))
            
            var newPath = NavigationPath()
            newPath.append(AppPages.authentication)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.path = newPath
            }
            
        default:
            path.append(page)
            break
        }
    }
    
    func pop(pages: [AppPages]) {
        guard path.count >= pages.count else { return }
        for page in pages {
            if let index = childs.firstIndex(where: {$0.type == page } ) {
                childs.remove(at: index)
            }
        }
        path.removeLast(pages.count)
    }
    
    func build(screen: AppPages) -> AnyView? {
        for child in childs {
            if let view = child.build(screen: screen) {
                return view
            }
        }
        return nil
    }
}

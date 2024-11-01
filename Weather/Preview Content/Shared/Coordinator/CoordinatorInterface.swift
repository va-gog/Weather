//
//  Coordinatorinterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

import SwiftUI

protocol CoordinatorInterface: AnyObject {
    associatedtype ViewType: View
    func start() -> ViewType
}

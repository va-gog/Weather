//
//  ForecastScreenToolbarTabType.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

import Foundation

enum ForecastScreenToolbarTabType: CaseIterable {
    case signOut
    case remove

    var title: String {
        switch self {
        case .signOut: return LocalizedText.signOut
        case .remove: return LocalizedText.remove
        }
    }

    var icon: String {
        switch self {
        case .signOut: return AppIcons.signOut
        case .remove: return AppIcons.remove
        }
    }
}

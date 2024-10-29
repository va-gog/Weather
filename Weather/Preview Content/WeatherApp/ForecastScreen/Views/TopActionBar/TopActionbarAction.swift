//
//  TopActionbarAction.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//
import Foundation

enum TopActionbarAction {
    case cancel
    case add
    
    var title: String {
       return switch self {
        case.add:
            NSLocalizedString("Add", comment: "")
            case .cancel:
            NSLocalizedString("Cancel", comment: "")
        }
    }
}

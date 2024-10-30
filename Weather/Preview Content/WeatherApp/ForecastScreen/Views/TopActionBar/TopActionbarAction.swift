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
           LocalizedText.add
            case .cancel:
           LocalizedText.cancel
        }
    }
}

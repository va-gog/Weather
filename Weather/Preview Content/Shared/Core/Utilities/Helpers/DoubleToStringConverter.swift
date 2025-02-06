//
//  DoubleToStringConverter.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import Foundation

struct DoubleToStringConverter {
    func formatDoubleToString(value: Double, decimalPlaces: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimalPlaces
        formatter.maximumFractionDigits = decimalPlaces
        formatter.decimalSeparator = ","

        if let formattedString = formatter.string(from: NSNumber(value: value)) {
            return formattedString
        }
        return "\(value)"
    }
}

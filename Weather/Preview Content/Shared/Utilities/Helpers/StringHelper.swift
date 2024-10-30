//
//  StringHelper.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

import Foundation

extension String {
    func localize() -> String {
        NSLocalizedString(self, comment: "")
    }
}

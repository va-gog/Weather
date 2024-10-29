//
//  AuthenticationError.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import Foundation

enum AuthenticationError: Error {
    case signin
    case tokenError(message: String)
}

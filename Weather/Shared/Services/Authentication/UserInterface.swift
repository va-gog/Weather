//
//  UserInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

import FirebaseAuth

protocol UserInterface {
    var uid: String { get }
}

extension User: UserInterface {}

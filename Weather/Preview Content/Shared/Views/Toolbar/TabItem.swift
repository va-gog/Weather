//
//  TabItem.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

import Foundation

protocol TabItem {
    var title: String { get }
    var icon: String { get }
    var isHidden: Bool { get }
}


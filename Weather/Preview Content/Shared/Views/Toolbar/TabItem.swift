//
//  TabItem.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//

import Foundation

protocol TabItem: CaseIterable, Hashable where AllCases: RandomAccessCollection {
    var title: String { get }
    var icon: String { get }
}

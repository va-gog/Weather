//
//  MainViewPresentationInfo.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import SwiftUI

struct MainViewPresentationInfo {
    var navigationTitle = NSLocalizedString("Weather", comment: "")
    var interitemSapec: CGFloat = 10
    var searchIcon = "magnifyingglass"
    var closeIcon = "xmark.circle.fill"
    var searchPlaceholder = "Search for a city or airport"
    var searchHeight: CGFloat = 35
    var cornerradius: CGFloat = 10
    var searchBackgroundColor = UIColor.systemGray5
}

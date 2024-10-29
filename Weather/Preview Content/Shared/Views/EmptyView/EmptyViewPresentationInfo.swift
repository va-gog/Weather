//
//  EmptyViewPresentationInfo.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import SwiftUI

struct EmptyViewPresentationInfo {
    var backgroundColor = Color.black
    var backgroundOpacity: CGFloat = 0.8
    var maxWidth: CGFloat = .infinity
    var maxHeight: CGFloat = .infinity
    var padding: CGFloat = 20
    
    var icon: String = "magnifyingglass"
    var iconForegroundColor = Color.white
    var iconWidth: CGFloat = 80
    var iconHeight: CGFloat = 80
    
    var titleSize: CGFloat = 22
    var titleWeight = Font.Weight.bold
    var titileForegroundColor = Color.white
    var titleAlignment = TextAlignment.center
    var titleMaxWidth: CGFloat = 100
    var titlemaxHeight: CGFloat = 50
    
    var subtitleSize: CGFloat = 15
    var subtitleWeight = Font.Weight.medium
    var subtitleForegroundColor = Color.white
    var subtitleAlignment = TextAlignment.center
    var subtitleHorizontalPadding: CGFloat = 30
}

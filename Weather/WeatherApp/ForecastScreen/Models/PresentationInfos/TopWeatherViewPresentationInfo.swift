//
//  TopWeatherViewPresentationInfo.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import SwiftUI

struct TopWeatherViewPresentationInfo {
    var spacing: CGFloat = 5
    var backgroundColor = UIColor.systemBackground
    var backgroundOpacity: CGFloat = 0.2
    var cornerRadius: CGFloat = 20
    var foregroundColor = Color.primary

    var imageRenderMode = Image.TemplateRenderingMode.original
    var imageShadow: CGFloat = 5
    var imageSize: CGFloat = 50

    var temperatureTextSize: CGFloat = 40
    var cityTextSize: CGFloat = 25
    var nameTextSize: CGFloat = 30

    var nameTextBoldIsActive = true
    var cityTextBoldIsActive = true
}

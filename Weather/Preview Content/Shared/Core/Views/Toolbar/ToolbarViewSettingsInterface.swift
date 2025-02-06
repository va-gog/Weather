//
//  ToolbarViewSettingsInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 13.11.24.
//

protocol ToolbarViewSettingsInterface {
    var selectedTab: TabItem? { get set }
    var tabItems: [TabItem] { get }
    var uiAttributes: BottomBarUIAttributes { get }
}

//
//  ToolbarViewSettings.swift
//  Weather
//
//  Created by Gohar Vardanyan on 13.11.24.
//

final class ToolbarViewSettings: ToolbarViewSettingsInterface {
    var selectedTab: TabItem?
    var tabItems: [TabItem]
    var uiAttributes: BottomBarUIAttributes
    
    init(tabItems: [TabItem],
         selectedTab: TabItem? = nil,
         uiAttributes: BottomBarUIAttributes = BottomBarUIAttributes()) {
        self.tabItems = tabItems
        self.selectedTab = selectedTab
        self.uiAttributes = uiAttributes
    }
}

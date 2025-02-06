//
//  TabItemFactory.swift
//  Weather
//
//  Created by Gohar Vardanyan on 13.11.24.
//

struct TabItemFactory {
    func createBottomToolbarItems(enabledTypes: [ForecastScreenToolbarTabType]) -> [TabItem] {
       return ForecastScreenToolbarTabType.allCases.map( { type in
            let isHidden = enabledTypes.first(where: { $0.title == type.title }) != nil
            return ForecastScreenToolbarTab(title: type.title,
                icon: type.icon,
                isHidden: isHidden)
        })
    }
}

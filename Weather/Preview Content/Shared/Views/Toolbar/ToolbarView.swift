//
//  ToolbarView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//


import SwiftUI

struct ToolbarView: View {
    @State var selectedRect: CGRect = .zero

    private var settings: ToolbarViewSettings
    private var onTab: (TabItem) -> Void
    
    init(settings: ToolbarViewSettings, onTab: @escaping (TabItem) -> Void) {
        self.settings = settings
        self.onTab = onTab
    }
    
    var body: some View {
        HStack(spacing: settings.uiAttributes.interTabSpace) {
            Spacer()
            ForEach(settings.tabItems, id: \.title) { tab in
                tabButton(for: tab)
            }
            Spacer()
        }
        .padding(.top, settings.uiAttributes.containerTopPadding)
        .background(settings.uiAttributes.toolbarBackground)
        .overlay(
            selectedTabIndicator,
            alignment: .bottomLeading
        )
    }
    
    private func tabButton(for tab: TabItem) -> some View {
        Button(action: {
            withAnimation {
                settings.selectedTab = tab
            }
            onTab(tab)
        }) {
            VStack {
                Image(systemName: tab.icon)
                    .resizable()
                    .frame(width: settings.uiAttributes.iconSize.width,
                           height: settings.uiAttributes.iconSize.height)
                Text(tab.title)
                    .font(settings.uiAttributes.textFont)
                    .padding(.top, settings.uiAttributes.textPadding.top)
            }
            .padding(.top, settings.uiAttributes.tabTopPadding)
            .foregroundColor(settings.selectedTab?.title == tab.title ? settings.uiAttributes.selectedForgroundColor : settings.uiAttributes.deselectedForgroundColor)
            .background(GeometryReader { geometry in
                Color.clear
                    .onAppear { updateSelectedRect(for: tab,
                                                   with: geometry) }
                    .onChange(of: settings.selectedTab?.title) { oldValue, newValue in
                        updateSelectedRect(for: tab,
                                           with: geometry)
                    }
                    .onChange(of: UIDevice.current.orientation) { _, _ in
                        updateSelectedRect(for: settings.selectedTab, with: geometry)
                           }
            })
        }
        .disabled(tab.isHidden)
        .buttonStyle(PlainButtonStyle())
    }
    
    private var selectedTabIndicator: some View {
        GeometryReader { geometry in
            Rectangle()
                .frame(width: selectedRect.width,
                       height: settings.uiAttributes.indicatorHeight)
                .foregroundColor(settings.uiAttributes.indicatorColor)
                .position(x: selectedRect.midX - geometry.frame(in: .global).minX,
                          y: 0)
                .animation(.easeInOut(duration: settings.uiAttributes.indicatorMoveAnimDur),
                           value: selectedRect)
        }
    }
    
    private func updateSelectedRect(for tab: TabItem?, with geometry: GeometryProxy) {
        if settings.selectedTab?.title == tab?.title {
            selectedRect = geometry.frame(in: .global)
        }
    }
}

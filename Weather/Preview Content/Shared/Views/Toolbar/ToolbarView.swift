//
//  ToolbarView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 30.10.24.
//


import SwiftUI

struct ToolbarView<T: TabItem>: View {
    @State private var selectedRect: CGRect = .zero
    @State private var selectedTab: T?
    
    private var uiAttributes: BottomBarUIAttributes
    private var onTab: (T) -> Void
    
    init(selectedTab: T?, attributes: BottomBarUIAttributes = BottomBarUIAttributes(), onTab: @escaping (T) -> Void) {
        self.selectedTab = selectedTab
        self.uiAttributes = attributes
        self.onTab = onTab
    }
    
    var body: some View {
        HStack(spacing: uiAttributes.interTabSpace) {
            Spacer()
            ForEach(T.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
            Spacer()
        }
        .padding(.top, uiAttributes.containerTopPadding)
        .background(uiAttributes.toolbarBackground)
        .overlay(
            selectedTabIndicator,
            alignment: .bottomLeading
        )
    }
    
    private func tabButton(for tab: T) -> some View {
        Button(action: {
            withAnimation {
                selectedTab = tab
            }
            onTab(tab)
        }) {
            VStack {
                Image(systemName: tab.icon)
                    .resizable()
                    .frame(width: uiAttributes.iconSize.width,
                           height: uiAttributes.iconSize.height)
                Text(tab.title)
                    .font(uiAttributes.textFont)
                    .padding(.top, uiAttributes.textPadding.top)
            }
            .padding(.top, uiAttributes.tabTopPadding)
            .foregroundColor(selectedTab == tab ? uiAttributes.selectedForgroundColor : uiAttributes.deselectedForgroundColor)
            .background(GeometryReader { geometry in
                Color.clear
                    .onAppear { updateSelectedRect(for: tab,
                                                   with: geometry) }
                    .onChange(of: selectedTab) { oldValue, newValue in
                        updateSelectedRect(for: tab,
                                           with: geometry)
                    }
                    .onChange(of: UIDevice.current.orientation) { _, _ in
                               updateSelectedRect(for: selectedTab, with: geometry)
                           }
            })
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var selectedTabIndicator: some View {
        GeometryReader { geometry in
            Rectangle()
                .frame(width: selectedRect.width,
                       height: uiAttributes.indicatorHeight)
                .foregroundColor(uiAttributes.indicatorColor)
                .position(x: selectedRect.midX - geometry.frame(in: .global).minX,
                          y: 0)
                .animation(.easeInOut(duration: uiAttributes.indicatorMoveAnimDur),
                           value: selectedRect)
        }
    }
    
    private func updateSelectedRect(for tab: T?, with geometry: GeometryProxy) {
        if selectedTab == tab {
            selectedRect = geometry.frame(in: .global)
        }
    }
}

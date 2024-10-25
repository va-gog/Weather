//
//  PaginationView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 24.10.24.
//

import SwiftUI

//struct PaginationView: View {
//    @Binding var selectedIndex: Int
//    @Binding var shouldShowLeftPlus: Bool
//    @Binding var shouldShowRightPlus: Bool
//    
//    let pagesCount: Int
//    let uiAttributes = PaginationViewUIAttributes()
//
//    var body: some View {
//        HStack(spacing: uiAttributes.spacing) {
//            Text(uiAttributes.moreImagesSymbol)
//                .modifier(MoreIconModifer(isVisible: $shouldShowLeftPlus))
//            pagingRectangles
//            Text(uiAttributes.moreImagesSymbol)
//                .modifier(MoreIconModifer(isVisible: $shouldShowRightPlus))
//        }
//        .animation(.easeInOut(duration: uiAttributes.animationDuration),
//                   value: selectedIndex)
//        .padding(.top, 10)
//    }
//    
//    private var pagingRectangles: some View {
//        return ForEach(0..<pagesCount, id: \.self) { index in
//            Rectangle()
//                .fill(index == selectedIndex ? uiAttributes.selectedColor : uiAttributes.deselectedColor)
//                .frame(width: uiAttributes.rectangleWidth,
//                       height: uiAttributes.rectangleHeight)
//        }
//    }
//    
//
//}

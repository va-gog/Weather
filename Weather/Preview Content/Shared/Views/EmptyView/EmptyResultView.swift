//
//  EmptyResultView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import SwiftUI

struct EmptyResultView: View {
    var title: String = ""
    var subtitle: String = ""
    
    var presentationInfo: EmptyViewPresentationInfo

    var body: some View {
        VStack {
            Image(systemName: presentationInfo.icon)
                .resizable()
                .scaledToFit()
                .frame(width: presentationInfo.iconWidth,
                       height: presentationInfo.iconHeight)
                .foregroundColor(presentationInfo.iconForegroundColor)

            Text(title)
                .font(.system(size: presentationInfo.titleSize,
                              weight: presentationInfo.titleWeight))
                .foregroundColor(presentationInfo.titileForegroundColor)
                .frame(minWidth: presentationInfo.titleMaxWidth,
                       minHeight: presentationInfo.titlemaxHeight)
                .multilineTextAlignment(presentationInfo.titleAlignment)
                .padding(.top, presentationInfo.padding)

            Text(subtitle)
                .font(.system(size: presentationInfo.subtitleSize,
                              weight: presentationInfo.subtitleWeight))
                .foregroundColor(.white)
                .multilineTextAlignment(presentationInfo.subtitleAlignment)
                .padding(.horizontal, presentationInfo.subtitleHorizontalPadding)
                .padding(.top, presentationInfo.padding)
        }
        .frame(maxWidth: presentationInfo.maxWidth,
               maxHeight: presentationInfo.maxWidth)
        .background(presentationInfo.backgroundColor
            .opacity(presentationInfo.backgroundOpacity))
        .edgesIgnoringSafeArea(.all)
    }
}

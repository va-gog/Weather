//
//  TopActionbar.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import SwiftUI

// TODO: Implement this as customizable view
struct TopActionbar: View {
    var style: WeatherDetailsViewStyle
    var presentationInfo: TopActionbarPresentationInfo
    var onAction: (TopActionbarAction) -> Void

    var body: some View {
        HStack {
            Text(TopActionbarAction.cancel.title)
                .foregroundColor(presentationInfo.foregroundColor)
                .padding(.leading, presentationInfo.paddingToParent)
                .onTapGesture {
                    withAnimation {
                        onAction(.cancel)
                    }
                }
            Spacer()
            
            if style != .overlayAdded {
                Text(TopActionbarAction.add.title)
                    .foregroundColor(presentationInfo.foregroundColor)
                    .padding(.trailing, presentationInfo.paddingToParent)
                    .onTapGesture {
                        withAnimation {
                            onAction(.add)                        }
                    }
            }
        }
        Spacer()
    }
}

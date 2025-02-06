//
//  SearchView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    
    var icon: String
    var placeholder: String
    var closeIcon: String
    var presentationInfo: SearchViewPresentationInfo
    var onSearchAction: (String) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(presentationInfo.imageForegroundColor)
                .padding(.leading,
                         presentationInfo.interitemSpace)
            TextField(placeholder,
                      text: $searchText)
                .foregroundColor(presentationInfo.textFieldForegroundColor)
                .onChange(of: searchText) { _, newValue in
                    onSearchAction(newValue)
                }
            Spacer()
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: closeIcon)
                        .foregroundColor(presentationInfo.clearButtonForegroundColor)
                }
                .padding(.trailing, 10)
            }
        }
        .frame(height: presentationInfo.height)
        .background(Color(.systemGray5))
        .cornerRadius(presentationInfo.cornerRadius)
    }
}

//
//  LocationPermitionScreen.swift
//  Weather
//
//  Created by Gohar Vardanyan on 07.11.24.
//

import SwiftUI

struct LocationPermitionView: View {
    
    var body: some View {
        VStack {
            Text(LocalizedText.locationAccess)
                .padding()
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text(LocalizedText.openSettings)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
            }
        }
    }
    
}

//
//  LoadingView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

import SwiftUI

struct LoadingView: View {
    private var presentationInfo = LoadingViewPresentationInfo()
    
    var body: some View {
       ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: presentationInfo.circularViewTint))
            .font(.system(size: presentationInfo.fontSize))
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}

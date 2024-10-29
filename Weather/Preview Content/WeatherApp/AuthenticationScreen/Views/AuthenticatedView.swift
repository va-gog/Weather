//
//  AuthenticatedView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 26.10.24.
//

import SwiftUI

struct AuthenticatedView<Content, Unauthenticated>: View where Content: View, Unauthenticated: View {
  @StateObject private var viewModel = AuthenticationViewModel(auth: AuthWrapper())
  @State private var presentingLoginScreen = false
  @State private var presentingProfileScreen = false

  var unauthenticated: Unauthenticated?
  @ViewBuilder var content: () -> Content

init(@ViewBuilder unauthenticated: @escaping () -> Unauthenticated, @ViewBuilder content: @escaping () -> Content) {
    self.unauthenticated = unauthenticated()
    self.content = content
  }

  var body: some View {
    switch viewModel.authenticationState {
    case .unauthenticated, .authenticating:
        AuthenticationView(type: $viewModel.flow)
          .environmentObject(viewModel)
    case .authenticated:
      VStack {
        content()
      }
    }
  }
}

extension AuthenticatedView where Unauthenticated == EmptyView {
  init(@ViewBuilder content: @escaping () -> Content) {
    self.unauthenticated = nil
    self.content = content
  }
}

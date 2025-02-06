//
//  AuthenticationView.swift
//  Weather
//
//  Created by Gohar Vardanyan on 26.10.24.
//

import SwiftUI
import Combine

private enum FocusableField: Hashable {
  case email
  case password
  case confirmPassword
}

// TODO: Can be changed to get texts and images from out

struct AuthenticationView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel
  @Environment(\.dismiss) var dismiss

  @FocusState private var focus: FocusableField?

    var body: some View {
        VStack {
            Text(viewModel.state.flow.titile)
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: AppIcons.email)
                TextField(LocalizedText.email,
                          text: $viewModel.state.email)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .password
                    }
            }
            .onChange(of: focus) { _, isFocused in
                if focus == .password, viewModel.state.flow == .login {
                    viewModel.send(AuthenticationViewAction.autofillPassword)
                }
            }
            .padding(.vertical, 6)
            .background(Divider(),
                        alignment: .bottom)
            .padding(.bottom, 4)
            
            HStack {
                Image(systemName: AppIcons.lock)
                SecureField(LocalizedText.password,
                            text: $viewModel.state.password)
                    .focused($focus,
                             equals: .password)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .confirmPassword
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(),
                        alignment: .bottom)
            .padding(.bottom, 8)
            
            if viewModel.state.flow == .signUp {
                HStack {
                    Image(systemName: AppIcons.lock)
                    SecureField(LocalizedText.confirmPassword,
                                text: $viewModel.state.confirmPassword)
                        .focused($focus,
                                 equals: .confirmPassword)
                        .submitLabel(.go)
                        .onSubmit {
                            signAction()
                        }
                }
                .padding(.vertical, 6)
                .background(Divider(),
                            alignment: .bottom)
                .padding(.bottom, 8)
            }
            
            
            if !viewModel.state.errorMessage.isEmpty {
                VStack {
                    Text(viewModel.state.errorMessage)
                        .foregroundColor(Color(UIColor.systemRed))
                }
            }
            
            Button(action: signAction) {
                if viewModel.state.authenticationState != .authenticating {
                    Text(viewModel.state.flow.buttonTitle)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(!viewModel.state.isValid)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            
            HStack {
                Text(viewModel.state.flow.changeModeText)
                Button(action: {
                    viewModel.send(AuthenticationViewAction.switchFlow)
                }) {
                    Text(viewModel.state.flow.next.titile)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding([.top, .bottom], 50)
            
        }
        .listStyle(.plain)
        .padding()
    }
    
    private func signAction() {
        viewModel.send(AuthenticationViewAction.signAction)
    }
}


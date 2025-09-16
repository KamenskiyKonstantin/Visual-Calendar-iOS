//
//  LoginView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 01.08.2024.
//

import SwiftUI

import Foundation

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var isCheckingSession = true
    
    @EnvironmentObject var warningManager: WarningHandler
    @EnvironmentObject var APIinteractor: APIHandler
    @EnvironmentObject var viewSwitcher: ViewSwitcher

    var body: some View {
        Group {
            if isCheckingSession {
                ProgressView("Checking session...")
            } else {
                NavigationStack {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack {
                                TextField("E-mail", text: $email)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)

                                SecureField("Password", text: $password)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .frame(width: 275, height: 100)
                            Spacer()
                        }

                        HStack {
                            Button("Log in") {
                                AsyncExecutor.runWithWarningHandler(warningHandler: warningManager, api: APIinteractor, viewSwitcher: viewSwitcher) {
                                    try await APIinteractor.login(email: email, password: password)
                                    if APIinteractor.isAuthenticated {
                                        viewSwitcher.switchToSelectRole()
                                    } else {
                                        throw AppError.authInvalidCredentials
                                    }
                                }
                            }
                            .frame(width: 250)
                            .buttonBorderShape(.capsule)
                            .background(Color.blue)
                            .cornerRadius(20)
                            .buttonStyle(BorderedButtonStyle())
                            .foregroundColor(.white)
                        }

                        HStack {
                            Spacer()
                            NavigationLink {
                                SignUpView(APIinteractor: APIinteractor)
                            } label: {
                                Text("Sign up")
                                    .frame(width: 200)
                            }
                            .buttonStyle(.borderless)
                            Spacer()
                        }

                        Spacer()
                    }
                }
            }
        }
        .task {
            AsyncExecutor.runWithWarningHandler(warningHandler: warningManager,api: APIinteractor, viewSwitcher: viewSwitcher) {
                defer {
                    isCheckingSession = false
                }
                if APIinteractor.isAuthenticated {
                    try await APIinteractor.verifySession()
                    viewSwitcher.switchToSelectRole()  // View logic stays in the view
                } else {
                    throw AppError.authSessionUnavailable
                }
            }
        }
    }
}

//
//  LoginView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 01.08.2024.
//

import SwiftUI

import Foundation

struct LoginView<ViewModel: LoginViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        if viewModel.isLoadingSession {
                ProgressView("Checking session...")
        }
        else {
            NavigationStack {
                HStack{
                    Spacer()
                        .frame(maxWidth: .infinity)
                    VStack {
                        Spacer()
                        VStack{
                            VStack {
                                TextField("E-mail", text: $viewModel.emailLogin)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)

                                SecureField("Password", text: $viewModel.passwordLogin)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Button("Log in") {
                                viewModel.login()
                            }
                            .frame(maxWidth: .infinity, maxHeight: 10)
                            .padding()
                            .buttonBorderShape(.automatic)
                            .background(Color.blue)
                            .cornerRadius(20)
                            .foregroundColor(.white)

                            NavigationLink {
                                SignUpView(viewModel: viewModel)
                            } label: {
                                Text("Sign up")
                                    .frame(width: 200)
                            }
                            .buttonStyle(.borderless)
                        }
                        #if DEBUG
                        //.border(Color.blue, width: 1)
                        #endif
                        Spacer()
                    }
                    #if DEBUG
                    //.border(Color.red, width: 1)
                    #endif
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
                
            }
            .task{
                viewModel.load()
            }
        }
        
    }
}

#Preview {
    LoginView(viewModel: MockLoginViewModel())
}


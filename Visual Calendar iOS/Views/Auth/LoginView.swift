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
            ProgressView("Auth.Login.Loading.ProgressView.Title".localized)
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
                                TextField("Auth.Login.Email.Field.Placeholder".localized, text: $viewModel.emailLogin)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)

                                SecureField("Auth.Login.Password.Field.Placeholder".localized, text: $viewModel.passwordLogin)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .frame(maxWidth: .infinity)
                            
                            HStack{
                                Spacer()
                                Button("Auth.Login.Login.Button.Title".localized) {
                                    viewModel.login()
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal,20)
                                .buttonBorderShape(.automatic)
                                .background(Color.blue)
                                .cornerRadius(30)
                                .foregroundColor(.white)
                                Spacer()
                            }
                            
                           

                            NavigationLink {
                                SignUpView(viewModel: viewModel)
                            } label: {
                                Text("Auth.Login.DontHaveAccount.Button.Title".localized)
                                    .frame(width: 200)
                            }
                            .buttonStyle(.borderless)
                        }
                        Spacer()
                    }
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


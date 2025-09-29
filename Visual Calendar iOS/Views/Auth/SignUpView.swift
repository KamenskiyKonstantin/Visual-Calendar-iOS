//
//  SignUpView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 03.08.2024.
//


import SwiftUI

struct SignUpView<ViewModel: LoginViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            HStack {
                Spacer()
                    .frame(maxWidth: .infinity)

                VStack {
                    Spacer()
                    
                    VStack {
                        VStack(spacing: 16) {
                            TextField("E-mail", text: $viewModel.emailSignup)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            VStack(spacing:7){
                                
                                SecureField("Password", text: $viewModel.passwordSignup)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                
                                SecureField("Confirm Password", text: $viewModel.confirmPasswordSignup)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                        }

                        Button("Sign Up") {
                            viewModel.signUp()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 10)
                        .padding()
                        .buttonBorderShape(.automatic)
                        .background(Color.blue)
                        .cornerRadius(20)
                        .foregroundColor(.white)

                        Button("Back to Login"){
                            dismiss()
                        }
                        .frame(width: 200)
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
    }
}
#Preview {
    SignUpView(viewModel: MockLoginViewModel())
}

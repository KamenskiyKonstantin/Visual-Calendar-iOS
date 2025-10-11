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
                            TextField("Auth.Signup.Email.Field.Placeholder", text: $viewModel.emailSignup)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            VStack(spacing:7){
                                
                                SecureField("Auth.Signup.Password.Field.Placeholder", text: $viewModel.passwordSignup)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                
                                SecureField("Auth.Signup.ConfirmPassword.Field.Placeholder", text: $viewModel.confirmPasswordSignup)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                        }
                        
                        HStack{
                            Spacer()
                                Button("Auth.Signup.Signup.Button.Title") {
                                    viewModel.signUp()
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .buttonBorderShape(.automatic)
                                .background(Color.blue)
                                .cornerRadius(20)
                                .foregroundColor(.white)
                            Spacer()
                        }

                        

                        Button("Auth.Signup.Cancel.Button.Title"){
                            dismiss()
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    Spacer()
                }

                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
#Preview {
    SignUpView(viewModel: MockLoginViewModel())
}

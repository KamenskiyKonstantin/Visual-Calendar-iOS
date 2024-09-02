//
//  LoginView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 01.08.2024.
//

import SwiftUI

import Foundation

func temp(){
    print("tejn")
}
struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var APIinteractor: ServerAPIinteractor
    @State private var viewSwitcher: ViewSwitcher
    init( APIinteractor: ServerAPIinteractor, viewSwitcher: ViewSwitcher) {
        self.APIinteractor = APIinteractor
        self.viewSwitcher = viewSwitcher
    }
    func login(){
        Task{
            await APIinteractor.login(email:email, password:password)
            if APIinteractor.authSuccessFlag{
                self.viewSwitcher.switchToSelectRole()
            }
        }
       
    }
    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    VStack{
                        TextField("E-mail",
                                  text: $email)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                        SecureField("Password",
                                    text: $password)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    }
                    .frame(width:275, height: 100, alignment: .center)
                    Spacer()
                }
                HStack{
                    
                    Button(action:login)
                    {
                        Text("Log in")
                            .frame(width:250)
                    }
                            .buttonBorderShape(.capsule)
                            .background(Color.blue)
                            .cornerRadius(20)
                            .buttonStyle(BorderedButtonStyle())
                            .foregroundColor(.white)
                    
                    
                }
                HStack{
                    Spacer()
                    NavigationLink
                    {
                        SignUpView(APIinteractor: APIinteractor)
                    }
                    label:
                    {
                        Text("Sign up")
                            .frame(width:200)
                    }
                    .buttonStyle(.borderless)
                    Spacer()
                }
                
                Spacer()
            }
        }
        
    }
}


#Preview {
    LoginView(APIinteractor: ServerAPIinteractor(), viewSwitcher: ViewSwitcher(apiHandler: ServerAPIinteractor()))
}


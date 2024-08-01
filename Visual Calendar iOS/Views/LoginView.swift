//
//  LoginView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 01.08.2024.
//

import SwiftUI

import Foundation

    class LoginViewModel: ObservableObject{
        @Published var email: String = ""
        @Published var password: String = ""
        
        func Login(){
            print(email, password)
        }
    }

func temp(){
    print("tejn")
}
struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var APIinteractor: ServerAPIinteractor
    init( APIinteractor: ServerAPIinteractor) {
        self.APIinteractor = APIinteractor
    }
    func login(){
        Task{
            await APIinteractor.login(email:email, password:password)
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
                        SecureField("Password",
                                    text: $password)
                    }
                    .frame(width:250, height: 100, alignment: .center)
                    Spacer()
                }
                HStack{
                    
                    Button(action:login)
                    {
                        Text("Log in")
                            .frame(width:250)
                    }
                    
                    
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
    LoginView(APIinteractor: ServerAPIinteractor())
}


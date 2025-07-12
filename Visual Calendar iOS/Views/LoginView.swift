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
    @State var APIinteractor: APIHandler
    @State var viewSwitcher: ViewSwitcher
    @State private var isCheckingSession = true
    func login(){
        Task{
            do{
                try await APIinteractor.login(email:email, password:password)
                if APIinteractor.isAuthenticated{
                    self.viewSwitcher.switchToSelectRole()
                }
            }
            catch{
                print(error.localizedDescription)
            }
        }
       
    }
    
    
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
                            .frame(width: 275, height: 100, alignment: .center)
                            Spacer()
                        }
                        HStack {
                            Button(action: login) {
                                Text("Log in")
                                    .frame(width: 250)
                            }
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
            if APIinteractor.isAuthenticated {
                viewSwitcher.switchToSelectRole()
            } else {
                print("No session found or restore failed")
            }
            isCheckingSession = false
        }
    }
}


#Preview {
        LoginView(APIinteractor: APIHandler(), viewSwitcher: ViewSwitcher(api: APIHandler()))

}


//
//  SignUpView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 03.08.2024.
//


import SwiftUI

struct SignUpView: View {
    @State var APIinteractor: APIHandler
    @State var email: String = ""
    @State var password: String = ""
    
    @EnvironmentObject var viewSwitcher: ViewSwitcher
    @EnvironmentObject var warningHandler: GlobalWarningHandler
    
    @Environment(\.dismiss) private var dismiss
    
    
    init(APIinteractor: APIHandler) {
        self.APIinteractor = APIinteractor
        
    }
    
    func signup() {
        Task{
            do{
                try await self.APIinteractor.signUp(email:email, password:password)
                try await self.APIinteractor.login(email:email, password:password)
                
                await MainActor.run {
                    if self.APIinteractor.isAuthenticated{
                        dismiss()
                        self.viewSwitcher.switchToSelectRole()
                        print("Signup successful")
                        print("Current view: \(self.viewSwitcher.activeView)")
                        
                    }
                    else{
                        self.viewSwitcher.switchToLogin()
                    }
                }
            }
            catch{
                warningHandler.showWarning("\(error)")
            }
            
        }
        
    }
    var body: some View{
        VStack{
            Spacer()
            HStack{
                Spacer()
                VStack{
                    TextField("E-mail",
                              text: $email)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    
                    SecureField("Password",
                                text: $password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                }
                .frame(width:250, height: 100, alignment: .center)
                Spacer()
            }
            HStack{
                
                Button(action:signup)
                {
                    Text("sign up")
                        .frame(width:250)
                }
                
            }
            Spacer()
        }
    }
}

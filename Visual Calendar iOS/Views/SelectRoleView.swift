//
//  SelectRoleView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 05.08.2024.
//

import SwiftUI

struct SelectRoleView: View {
    @State private var viewSwitcher: ViewSwitcher
    init(viewSwitcher: ViewSwitcher) {
        self.viewSwitcher = viewSwitcher
    }
    var body: some View {
        VStack{
            NavigationStack{
                Spacer()
                HStack{
                    Spacer()
                    Text("Please select your role")
                    Spacer()
                }
                VStack{
                    HStack{
                        Spacer()
                        //TODO: Child button is for test functionality, switchToLogin must be replaced
                        Button(action:self.viewSwitcher.switchToLogin)
                        {
                            Text("Child")
                                .frame(width:400)
                        }
                        .buttonBorderShape(.capsule)
                        .background(Color.blue)
                        .cornerRadius(20)
                        .buttonStyle(BorderedButtonStyle())
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        Spacer()
                    }
                    
                    HStack{
                        NavigationLink
                        {
                            ConfirmAdultView()
                        }
                    label:
                        {
                            Text("Adult")
                                .frame(width:400)
                            
                        }
                        .buttonBorderShape(.capsule)
                        .background(Color.blue)
                        .cornerRadius(20)
                        .buttonStyle(BorderedButtonStyle())
                        .foregroundColor(.white)
                        
                    }
                }
                
                HStack{
                    Spacer()
                    
                }
                Spacer()
            }
            
            
        }
    }
}

struct ConfirmAdultView: View{
    var verificationValA: Int = Int.random(in: 10...100)
    var verificationValB: Int = Int.random(in: 10...100)
    var body: some View{
        VStack{
            Spacer()
            HStack{
                Spacer()
                Text("Please verify that you are an adult by solving this equation")
                Spacer()
            }
            //TODO: add captcha
            Spacer()
        }
    }
    
}

#Preview {
    SelectRoleView(viewSwitcher: ViewSwitcher())
}

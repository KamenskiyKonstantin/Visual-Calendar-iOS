//
//  SelectRoleView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 05.08.2024.
//

import SwiftUI

struct SelectRoleView: View {
    @State private var viewSwitcher: ViewSwitcher
    @EnvironmentObject var warningHandler: WarningHandler
    @EnvironmentObject var api: APIHandler
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
                        Button(action:{
                            AsyncExecutor.runWithWarningHandler(warningHandler: warningHandler,  api: api, viewSwitcher: viewSwitcher,) {
                                try await viewSwitcher.switchToCalendar(isAdult: false)
                            }})
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
                            ConfirmAdultView(viewSwitcher: viewSwitcher)
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
    @State var userAnswer: String = ""
    @EnvironmentObject var api: APIHandler
    
    var verificationValA: Int = Int.random(in: 1...10)
    var verificationValB: Int = Int.random(in: 1...10)
    
    var viewSwitcher: ViewSwitcher
    
    @EnvironmentObject var warningHandler: WarningHandler
    
    
    var body: some View{
        VStack{
            Spacer()
            HStack{
                Spacer()
                VStack{
                    Spacer()
                    Text("Please verify that you are an adult by solving this equation")
                    Text("\(verificationValA) + \(verificationValB) = ?")
                    TextField("Answer", text: $userAnswer)
                        .padding(10)
                        .frame(width: 200)
                    
                    Button("Submit", action: checkAnswer)
                        .buttonBorderShape(.capsule)
                        .frame(width: 200)
                        .padding(10)
                        .background(Color.accentColor)
                        .foregroundColor(Color.white)
                        .cornerRadius(20)
                    Spacer()
                    
                    
                }
                
                Spacer()
            }
            Spacer()
        }
        
    }
    
    func checkAnswer() {
        guard !userAnswer.isEmpty else {
            warningHandler.showWarning("Please provide an answer")
            return
        }
        
        guard let answer = Int(userAnswer) else {
            warningHandler.showWarning("Please enter a valid number")
            return
        }
        
        if answer == verificationValA + verificationValB {
            AsyncExecutor.runWithWarningHandler(warningHandler: warningHandler, api: api, viewSwitcher: viewSwitcher) {
                try await viewSwitcher.switchToCalendar(isAdult: true)
            }
        } else {
            warningHandler.showWarning("Incorrect answer. Please try again")
        }
    }
}


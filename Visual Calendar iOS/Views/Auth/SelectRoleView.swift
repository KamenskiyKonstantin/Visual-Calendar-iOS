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
                        Button(action:{self.viewSwitcher.switchToCalendar(isAdult: false)})
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
    
    var verificationValA: Int = Int.random(in: 1...10)
    var verificationValB: Int = Int.random(in: 1...10)
    
    var viewSwitcher: ViewSwitcher
    
    @State var isAlertPresented: Bool = false
    
    
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
        .sheet(isPresented: $isAlertPresented) {
            messageBox(text: "Incorrect answer", isVisible: $isAlertPresented)
        }
        
    }
    
    func checkAnswer(){
        if userAnswer.isEmpty{
            isAlertPresented.toggle()
        }
        else{
            if Int(userAnswer)! == verificationValA + verificationValB {
                viewSwitcher.switchToCalendar(isAdult:true)
            }else{
                isAlertPresented.toggle()
            }
        }
    }
    
}


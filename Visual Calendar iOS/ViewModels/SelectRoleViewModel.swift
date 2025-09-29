//
//  SelectRoleView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 29.09.2025.
//

import Foundation

@MainActor
class SelectRoleViewModel: ObservableObject {
    private var hasLoaded: Bool = false
    
    @Published var userVerificationAnswer: String = ""
    
    @Published var verificationValA: Int = Int.random(in: 1...10)
    @Published var verificationValB: Int = Int.random(in: 1...10)
    
    private var api: APIHandler
    private var viewSwitcher: ViewSwitcher
    private var warningHandler: WarningHandler
    
    init(api: APIHandler, viewSwitcher: ViewSwitcher, warningHandler: WarningHandler) {
        self.api = api
        self.viewSwitcher = viewSwitcher
        self.warningHandler = warningHandler
    }
    
    func load() {
        if !hasLoaded {
            let role = UserDefaultsManager.shared.getRole()
            switch role {
                case .child:
                    switchChild()
                case .adult:
                    forceSwitchAdult()
            case nil:
                return
            }
            hasLoaded = true
        }
        
    }
    
    func reset() {
        hasLoaded = false
    }
    
    func switchChild(){
        UserDefaultsManager.shared.saveRole(.child)
        viewSwitcher.switchToCalendar(isAdult: false)
    }
    
    func switchAdult(){
        if userVerificationAnswer.isEmpty {
            warningHandler.showWarning("Please answer the question")
            return
        }
        else{
            if userVerificationAnswer != "\(verificationValA + verificationValB)"{
                warningHandler.showWarning("Incorrect answer")
                return
            }
        }
        UserDefaultsManager.shared.saveRole(.adult)
        viewSwitcher.switchToCalendar(isAdult: true)
    }
    
    private func forceSwitchAdult() {
        UserDefaultsManager.shared.saveRole(.adult)
        viewSwitcher.switchToCalendar(isAdult: true)
    }
    
    
    
    
    
}

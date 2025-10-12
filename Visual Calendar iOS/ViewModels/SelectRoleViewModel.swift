//
//  SelectRoleView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 29.09.2025.
//

import Foundation

@MainActor
protocol SelectRoleViewModelProtocol: ObservableObject {
    var userVerificationAnswer: String { get set}
    
    var verificationValA: Int { get set}
    var verificationValB: Int { get set}
    
    func load()
    func reset()
    
    func switchChild()
    func switchAdult()
    
}

@MainActor
class SelectRoleViewModel: SelectRoleViewModelProtocol {
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
        verificationValA = Int.random(in: 1...10)
        verificationValB = Int.random(in: 1...10)
        userVerificationAnswer = ""
        
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

class MockSelectRoleViewModel: SelectRoleViewModelProtocol{
    @Published var userVerificationAnswer: String = "7"
    @Published var verificationValA: Int = 1
    @Published var verificationValB: Int = 6
    
    func load() {
        print("Load")
    }
    
    func reset() {
        print("Reset")
    }
    
    func switchAdult() {
        print("Switch Adult")
    }
    
    func switchChild() {
        print("Switch Child")
    }
}

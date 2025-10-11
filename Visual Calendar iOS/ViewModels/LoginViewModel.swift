//
//  LoginViewModel.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 22.09.2025.
//


import Foundation
import SwiftUI

@MainActor
protocol LoginViewModelProtocol: ObservableObject {
    
    var emailLogin: String {get set}
    var passwordLogin: String {get set}
    var emailSignup: String {get set}
    var passwordSignup: String {get set}
    var confirmPasswordSignup: String {get set}
    var isLoadingSession: Bool {get set}
    
    func load()
    
    func signUp()
    func login()
    
    func reset()
}

@MainActor
final class LoginViewModel: LoginViewModelProtocol {
    // Internal flow control
    private var hasLoaded: Bool = false

    // Login credentials
    @Published var emailLogin: String = ""
    @Published var passwordLogin: String = ""

    // Signup credentials
    @Published var emailSignup: String = ""
    @Published var passwordSignup: String = ""
    @Published var confirmPasswordSignup: String = ""
    
    // View states
    @Published var isLoadingSession: Bool = false

    // Dependencies
    private let api: APIHandler
    private let viewSwitcher: ViewSwitcher

    init(api: APIHandler, viewSwitcher: ViewSwitcher) {
        self.api = api
        self.viewSwitcher = viewSwitcher
    }
    
    func load(){
        if !hasLoaded {
            Task {
                isLoadingSession = true
                let hasSession = await api.verifySession(true)
                if hasSession {viewSwitcher.switchToSelectRole()}
                print("LOADING LOGINVIEW COMPLETE")
                hasLoaded = true
                isLoadingSession = false
            }
        }
    }

    func login() {
        Task {
            let success = await api.login(
                email: emailLogin,
                password: passwordLogin
            )
            if success {
                viewSwitcher.switchToSelectRole()
            }
        }
    }

    func signUp() {
        Task {
            let success = await api.signUp(
                email: emailSignup,
                password: passwordSignup,
                confirmPassword: confirmPasswordSignup
            )
            if success {
                viewSwitcher.switchToSelectRole()
            }
        }
    }
    
    func reset() {
        hasLoaded = false
        emailLogin = ""
        passwordLogin = ""
        emailSignup = ""
        passwordSignup = ""
        confirmPasswordSignup = ""
    }
}


@MainActor
class MockLoginViewModel:LoginViewModelProtocol{
    @Published var emailLogin: String = "testemail@example.com"
    @Published var passwordLogin: String = "password"
    
    @Published var emailSignup: String = "testemail@example.com"
    @Published var passwordSignup: String = "password"
    @Published var confirmPasswordSignup: String = "password"
    
    @Published var isLoadingSession: Bool = false
    
    func load() {
        print("Loading View Model")
    }
    
    func login() {
        print("Logging in")
    }
    
    func signUp() {
        print("Signing up")
    }
    
    func reset() {
        print("Resetting")
    }
    
}

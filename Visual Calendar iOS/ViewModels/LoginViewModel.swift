//
//  LoginViewModel.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 22.09.2025.
//

import Foundation


@MainActor
final class LoginViewModel: ObservableObject {
    // MARK: VIEW INPUTS
    @Published var email: String = ""
    @Published var password: String = ""
    // MARK: VIEW STATES
    @Published var isCheckingSession: Bool = true
    
    
    // MARK: DEPENDENCIES
    let api: APIHandler
    let viewSwitcher: ViewSwitcher
    
    init(api: APIHandler, viewSwitcher: ViewSwitcher){
        self.api = api
        self.viewSwitcher = viewSwitcher
    }
    
    func checkSessionIfNeeded(){
        if isCheckingSession{
            Task{
                defer {
                    isCheckingSession = false
                }
                do {
                    try await api.verifySession()
                    
                }
                catch {
                
                }
            }
        }
    }
    
    
    
    
}

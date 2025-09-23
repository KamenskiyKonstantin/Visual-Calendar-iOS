@MainActor
class WarningHandler: ObservableObject {
    @Published var message: String = ""
    @Published var isShown: Bool = false


    func showWarning(_ message: String) {
        self.message = message
        self.isShown = true
    }

    func hideWarning() {
        message = ""
        isShown = false
    }

    func forceLogout(with message: String? = nil, api: APIHandler, viewSwitcher: ViewSwitcher) {
        if let msg = message {
            showWarning(msg)
        }
        Task{
            do {
                try await api.logout()
                viewSwitcher.switchToLogin()
                
            }
            catch {}
        }
    }
}
    

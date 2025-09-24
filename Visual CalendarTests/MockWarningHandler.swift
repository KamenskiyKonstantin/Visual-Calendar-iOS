//
//  MockWarningHandler.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 22.09.2025.
//

@MainActor
final class MockWarningHandler: WarningHandler {
    private(set) var shownMessages: [String] = []

    override func showWarning(_ message: String) {
        super.showWarning(message)
        shownMessages.append(message)
    }

    var lastWarning: String? {
        shownMessages.last
    }

    var wasWarningShown: Bool {
        !shownMessages.isEmpty
    }

    func clear() {
        shownMessages.removeAll()
    }
}

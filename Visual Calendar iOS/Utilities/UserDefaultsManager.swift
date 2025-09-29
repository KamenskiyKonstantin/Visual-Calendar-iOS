//
//  UserDefaultsManager.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 29.09.2025.
//
import Foundation

enum UserRole: String, Codable {
    case child
    case adult
}

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()

    private let roleKey = "com.calmtable.app.userRole"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Role
    func saveRole(_ role: UserRole) {
        defaults.set(role.rawValue, forKey: roleKey)
    }

    func getRole() -> UserRole? {
        guard let raw = defaults.string(forKey: roleKey) else { return nil }
        return UserRole(rawValue: raw)
    }

    func clearRole() {
        defaults.removeObject(forKey: roleKey)
    }

    // MARK: - Global Purge
    func clearAll() {
        clearRole()
        // Add any other keys you want to clear in future
    }
}

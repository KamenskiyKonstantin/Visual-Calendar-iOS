import Foundation

enum AppError: Error {
    case auth(Auth)
    case storage(Storage)
    case input(Validation)
    case network
    case backend(reason: String)
    case unknown(Error)

    enum Auth: Error {
        case invalidCredentials
        case sessionUnavailable
        case unauthorized
    }

    enum Storage: Error {
        case duplicateFile
        case duplicateLibrary
        case fileNotFound
        case libraryNotFound(String)
    }

    enum Validation: Error {
        case invalidInput(reason: String)
    }
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .auth(let error): return error.localizedDescription
        case .storage(let error): return error.localizedDescription
        case .input(let error): return error.localizedDescription
        case .network: return "Network error. Please try again."
        case .backend(let reason): return reason
        case .unknown(let error): return "Unexpected error: \(error.localizedDescription)"
        }
    }
}

extension AppError.Auth: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Incorrect email or password."
        case .sessionUnavailable: return "Session could not be restored."
        case .unauthorized: return "Unauthorized access."
        }
    }
}

extension AppError.Storage: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .duplicateFile: return "You've already added this file."
        case .duplicateLibrary: return "You've already added this library."
        case .fileNotFound: return "File not found."
        case .libraryNotFound(let name): return "Library not found: \(name)"
        }
    }
}

extension AppError.Validation: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidInput(let reason): return reason
        }
    }
}
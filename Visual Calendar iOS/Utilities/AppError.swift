//
//  AppError.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 17.07.2025.
//


import Foundation

enum AppError: Error, LocalizedError, Equatable{
    // MARK: - Auth / Session
    case authInvalidCredentials
    case authSessionUnavailable
    case authSessionExpired

    // MARK: - Network/API
    case networkUnavailable
    case serverError(String)
    case decodingFailed
    case unauthorized
    case resourceNotFound
    case timeout
    case badRequest
    case apiError(String)
    
    // UNIQUE Constraints
    case duplicateLibrary
    case duplicateFile

    // MARK: - Domain-specific
    case failedToFetchImages
    case failedToFetchEvents
    case failedToFetchPresets
    case failedToFetchLibraries
    case failedToAddLibrary
    case failedToUploadImage
    case failedToUpsertEvents
    case failedToUpsertPreset
    case failedToReadFile
    case libraryNotFound(String)

    // MARK: - Unknown / fallback
    case unknown(Error)
    case multipleErrorsOccurred([AppError])
    
    var errorDescription: String? {
        switch self {
        case .authInvalidCredentials: return "Invalid login credentials. Please try again."
        case .authSessionUnavailable: return "No session found. Please log in again."
        case .authSessionExpired: return "Your session has expired. Please log in again."
            
        case .duplicateFile: return "A file with the same name already exists."
        case .duplicateLibrary: return "A library with the same name is already added"
            
        case .networkUnavailable: return "Network connection appears to be offline."
        case .serverError(let message): return "Server error: \(message)"
        case .decodingFailed: return "Failed to decode data from server."
        case .unauthorized: return "You are not authorized to perform this action."
        case .resourceNotFound: return "Requested resource was not found."
        case .timeout: return "The request timed out. Try again."
        case .badRequest: return "The request was invalid."
        case .apiError(let message): return "API error: \(message)"
        
        case .failedToFetchImages: return "Could not load images from the server."
        case .failedToFetchEvents: return "Could not fetch calendar events."
        case .failedToFetchPresets: return "Could not fetch event presets."
        case .failedToFetchLibraries: return "Could not fetch available libraries."
        case .failedToAddLibrary: return "Could not add the standard library."
        case .failedToUploadImage: return "Image upload failed."
        case .failedToUpsertEvents: return "Failed to save your changes to events."
        case .failedToUpsertPreset: return "Failed to save the event preset."
        case .failedToReadFile: return "Could not read the selected file."
        case .libraryNotFound(let name): return "Library not found: \(name)."
        
        case .unknown(let error): return "An unknown error occurred: \(error.localizedDescription)."
        case .multipleErrorsOccurred(let errors):
            return "Several operations failed:\n" + errors.map { $0.localizedDescription }.joined(separator: "\n")
        }
    }
    
    var isFatal: Bool {
        if self == .authSessionExpired {
            return true
        }
        
        return false
    }
    
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}


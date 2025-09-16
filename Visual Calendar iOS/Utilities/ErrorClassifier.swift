//
//  ErrorClassifier.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 17.07.2025.
//


import Foundation

struct ErrorClassifier {
    static func classifyAndThrow(_ error: Error, job: String = "Unknown job") throws -> Never {
        let classified: AppError

        if let appError = error as? AppError {
            classified = appError
        } else {
            let msg = error.localizedDescription.lowercased()

            if msg.contains("duplicate key value violates unique constraint") {
                if msg.contains("custom_files") {
                    classified = .duplicateFile
                } else if msg.contains("connected_libraries") {
                    classified = .duplicateLibrary
                } else {
                    classified = .unknown(error)
                }

            } else if msg.contains("jwt expired") || msg.contains("invalid token") || msg.contains("restore session")  {
                classified = .authSessionUnavailable

            } else if msg.contains("network") || msg.contains("offline") {
                classified = .networkUnavailable

            } else if msg.contains("timeout") {
                classified = .timeout
            }
            else if msg.contains("refresh token"){
                classified = .authSessionUnavailable
            } else {
                classified = .unknown(error)
            }
        }

        log(classified, original: error, job: job)
        throw classified
    }

    private static func log(_ classified: AppError, original: Error, job: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        print("\(timestamp)] Job <\(job)> ended with error:\(original.localizedDescription) → Classified as: \(classified.localizedDescription)")
    }
}

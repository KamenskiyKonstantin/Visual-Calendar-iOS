//
//  AsyncExecutor.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 20.07.2025.
//
import Foundation

struct AsyncResult<T> {
    let value: T?
    let error: Error?

    init(value: T) {
        self.value = value
        self.error = nil
    }

    init(error: Error) {
        self.value = nil
        self.error = error
    }

    var succeeded: Bool { value != nil }
    var failed: Bool { error != nil }
}

extension AsyncResult {
    static func success(_ value: T) -> AsyncResult<T> {
        .init(value: value)
    }

    static func failure(_ error: Error) -> AsyncResult<T> {
        .init(error: error)
    }
}

@MainActor
final class AsyncExecutor {
    private let warningHandler: WarningHandler
    private let logoutSequence: @Sendable () async throws -> Void

    init(warningHandler: WarningHandler,
        logoutSequence: @escaping @Sendable () async throws -> Void)
    {
        self.warningHandler = warningHandler
        self.logoutSequence = logoutSequence
    }

    func run<T>(
        _ jobName: String = "Unnamed job",
        _ beQuiet: Bool = false,
        _ operation: @escaping @Sendable () async throws -> T
    ) async -> AsyncResult<T> {
        do {
            let result = try await operation()
            return .success(result)
        } catch {
            
            do {
                try ErrorClassifier.classifyAndThrow(error)
            }
            catch{
                if !beQuiet{
                    let message = String(
                        format: NSLocalizedString("Job.Error.Description", comment: "Error message shown when a job fails"),
                        jobName,
                        error.localizedDescription
                    )
                    warningHandler.showWarning(message)
                }
                if error is AppError{
                    if error as! AppError == .authSessionExpired{
                        try? await logoutSequence()
                    }
                }
                
                print("[-EXECUTOR/RUN-] JOB FAILED: \(jobName) with low-level error: \(error)")
                return .failure(error)
            }
            }
            
            
    }
}

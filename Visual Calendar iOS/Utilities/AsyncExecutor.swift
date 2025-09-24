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

#if TESTING
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
        _ operation: @escaping @Sendable () async throws -> T
    ) async -> AsyncResult<T> {
        do {
            let result = try await operation()
            return .success(result)
        } catch {
            await warningHandler.showWarning("Error during \(jobName): \(error.localizedDescription)")
            try? await logoutSequence()
            print("[-EXECUTOR/RUN-] JOB FAILED: \(jobName) with low-level error: \(error)")
            return .failure(error)
        }
    }
}
#else
@MainActor
struct AsyncExecutor {
    static func runWithWarningHandler(
        warningHandler: WarningHandler,
        api: APIHandler,
        viewSwitcher: ViewSwitcher,
        task: @escaping () async throws -> Void
    ) {
        Task {
            do {
                try await task()
            } catch {
                if let appError = error as? AppError, appError.isFatal {
                    print("Fatal error: \(error)")
                    warningHandler.forceLogout(with: appError.localizedDescription, api: api, viewSwitcher: viewSwitcher)
                } else {
                    warningHandler.showWarning(error.localizedDescription)
                }
            }
        }
    }
}
#endif

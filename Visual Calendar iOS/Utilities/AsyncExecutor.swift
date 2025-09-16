//
//  AsyncExecutor.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 20.07.2025.
//


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

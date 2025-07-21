@MainActor
struct AsyncExecutor {
    static func runWithWarningHandler(
        warningHandler: WarningHandler,
        task: @escaping () async throws -> Void
    ) {
        Task {
            do {
                try await task()
            } catch {
                if let appError = error as? AppError, appError.isFatal {
                    warningHandler.forceLogout(with: appError.localizedDescription)
                } else {
                    warningHandler.showWarning(error.localizedDescription)
                }
            }
        }
    }
}
import Foundation

struct ErrorClassifier {
    static func classifyAndThrow(_ error: Error, job: String = "Unknown job") throws -> Never {
        let classified: APIError

        if let apiError = error as? APIError {
            classified = apiError
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
            } else if msg.contains("jwt expired") || msg.contains("invalid token") {
                classified = .unauthorized
            } else if msg.contains("network") || msg.contains("timeout") {
                classified = .networkError
            } else {
                classified = .unknown(error)
            }
        }

        logError(classified, original: error, job: job)
        throw classified
    }

    private static func logError(_ classified: APIError, original: Error, job: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let message = """
        [\(timestamp)]:
        <\(job)> ended with the following error:
        \(original.localizedDescription)
        Classified as: \(classified.localizedDescription)
        """
        print(message)
    }
}
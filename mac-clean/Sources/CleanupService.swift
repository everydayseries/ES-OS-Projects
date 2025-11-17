import Foundation

actor CleanupService {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func estimateSize(for category: StorageCategory) -> UInt64 {
        resolvedTargets(for: category).reduce(0) { partialResult, url in
            partialResult + FileSizeCalculator.sizeOfItem(at: url, fileManager: fileManager)
        }
    }

    func clean(category: StorageCategory) -> CleanupResult {
        let targets = resolvedTargets(for: category)
        var removedBytes: UInt64 = 0
        var removedItems = 0
        var failures: [String] = []

        for url in targets {
            guard !isProtected(url: url) else {
                failures.append("Skipping protected path: \(url.path)")
                continue
            }

            let sizeBefore = FileSizeCalculator.sizeOfItem(at: url, fileManager: fileManager)

            do {
                try removeItem(at: url)
                removedItems += 1
                removedBytes += sizeBefore
            } catch {
                failures.append("\(url.lastPathComponent): \(error.localizedDescription)")
            }
        }

        return CleanupResult(removedBytes: removedBytes, removedItems: removedItems, failures: failures)
    }

    private func resolvedTargets(for category: StorageCategory) -> [URL] {
        category.paths.flatMap { pattern in
            CleanupPathResolver.resolve(pattern: pattern, fileManager: fileManager)
                .filter { fileManager.fileExists(atPath: $0.path) }
        }
    }

    private func removeItem(at url: URL) throws {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        guard exists else { return }

        if isDirectory.boolValue {
            try fileManager.removeItem(at: url)
        } else {
            try fileManager.removeItem(at: url)
        }
    }

    private func isProtected(url: URL) -> Bool {
        let forbiddenPaths = ["/", "/System", "/usr", "/bin", "/sbin"]
        if forbiddenPaths.contains(url.path) {
            return true
        }
        let home = fileManager.homeDirectoryForCurrentUser
        return url == home
    }
}

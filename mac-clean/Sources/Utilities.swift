import Foundation
import Darwin

enum DiskUtility {
    static func fetchUsage() -> DiskUsage {
        var stats = statfs()
        if statfs("/", &stats) == 0 {
            let blockSize = UInt64(stats.f_bsize)
            let total = blockSize * UInt64(stats.f_blocks)
            let free = blockSize * UInt64(stats.f_bavail)
            return DiskUsage(totalBytes: total, freeBytes: free)
        }
        return .empty
    }

    static func openInTerminal(paths: [String], fileManager: FileManager = .default) -> String? {
        guard let target = paths.compactMap({ expand($0) }).first(where: { fileManager.fileExists(atPath: $0) }) else {
            return "Nothing to open for this category."
        }

        let process = Process()
        process.launchPath = "/usr/bin/open"
        process.arguments = ["-a", "Terminal", target]

        do {
            try process.run()
            return nil
        } catch {
            return "Failed to open Terminal: \(error.localizedDescription)"
        }
    }

    private static func expand(_ path: String) -> String {
        NSString(string: path.replacingOccurrences(of: "/*", with: "")).expandingTildeInPath
    }
}

enum CleanupPathResolver {
    static func resolve(pattern: String, fileManager: FileManager = .default) -> [URL] {
        let expanded = NSString(string: pattern).expandingTildeInPath

        if expanded.contains("*") {
            return resolveWildcardPath(expandedPath: expanded, fileManager: fileManager)
        }

        let url = URL(fileURLWithPath: expanded)
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDir) else {
            return []
        }
        return [url]
    }

    private static func resolveWildcardPath(expandedPath: String, fileManager: FileManager) -> [URL] {
        // Only support trailing /* so we can clean folder contents without deleting the folder itself
        guard expandedPath.hasSuffix("/*") else { return [] }
        let basePath = String(expandedPath.dropLast(2))
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: basePath, isDirectory: &isDir), isDir.boolValue else {
            return []
        }
        guard let items = try? fileManager.contentsOfDirectory(atPath: basePath) else {
            return []
        }
        return items.map { URL(fileURLWithPath: basePath).appendingPathComponent($0) }
    }
}

enum FileSizeCalculator {
    static func sizeOfItem(at url: URL, fileManager: FileManager = .default) -> UInt64 {
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            return 0
        }

        if !isDirectory.boolValue {
            return singleFileSize(at: url)
        }

        var total: UInt64 = 0
        if let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey, .totalFileAllocatedSizeKey, .fileAllocatedSizeKey, .isDirectoryKey],
            options: [.skipsHiddenFiles],
            errorHandler: { _, _ in true }
        ) {
            for case let fileURL as URL in enumerator {
                total += sizeForURL(fileURL)
            }
        }

        // Include small empty directories as 0 bytes
        return total
    }

    private static func singleFileSize(at url: URL) -> UInt64 {
        return sizeForURL(url)
    }

    private static func sizeForURL(_ url: URL) -> UInt64 {
        if let values = try? url.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey]) {
            if let allocated = values.totalFileAllocatedSize {
                return UInt64(allocated)
            }
            if let fallback = values.fileAllocatedSize {
                return UInt64(fallback)
            }
        }

        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
           let size = attributes[.size] as? NSNumber {
            return size.uint64Value
        }

        return 0
    }
}

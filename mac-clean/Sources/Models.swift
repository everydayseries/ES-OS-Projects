import Foundation

struct DiskUsage: Sendable {
    let totalBytes: UInt64
    let freeBytes: UInt64

    var usedBytes: UInt64 {
        totalBytes > freeBytes ? totalBytes - freeBytes : 0
    }

    var usedFraction: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(usedBytes) / Double(totalBytes)
    }

    var freeFraction: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(freeBytes) / Double(totalBytes)
    }

    static let empty = DiskUsage(totalBytes: 0, freeBytes: 0)
}

struct StorageCategory: Identifiable, Hashable, Sendable {
    enum SafetyLevel: String, Sendable {
        case safe = "Safe"
        case caution = "Caution"
        case advanced = "Advanced"
    }

    typealias ID = String

    let id: ID
    let title: String
    let iconName: String
    let detail: String
    let safety: SafetyLevel
    let paths: [String]
    let requiresElevatedAccess: Bool
}

extension StorageCategory {
    static let presets: [StorageCategory] = [
        StorageCategory(
            id: "trash",
            title: "Trash Bin",
            iconName: "trash",
            detail: "Empty everything inside ~/.Trash.",
            safety: .safe,
            paths: ["~/.Trash/*"],
            requiresElevatedAccess: false
        ),
        StorageCategory(
            id: "mail-attachments",
            title: "Mail Attachments",
            iconName: "envelope.badge.fill",
            detail: "Remove downloaded Mail attachments (messages stay intact).",
            safety: .safe,
            paths: [
                "~/Library/Containers/com.apple.mail/Data/Library/Mail Downloads/*",
                "~/Library/Containers/com.apple.mail/Data/Library/Application Support/Mail/Attachments/*"
            ],
            requiresElevatedAccess: false
        ),
        StorageCategory(
            id: "user-cache-files",
            title: "User Cache Files",
            iconName: "internaldrive",
            detail: "Clear ~/Library/Caches (apps recreate these files automatically).",
            safety: .safe,
            paths: ["~/Library/Caches/*"],
            requiresElevatedAccess: false
        ),
        StorageCategory(
            id: "user-log-files",
            title: "User Log Files",
            iconName: "doc.text.fill",
            detail: "Clear crash logs and diagnostic reports stored in your Library.",
            safety: .safe,
            paths: [
                "~/Library/Logs/*",
                "~/Library/Logs/DiagnosticReports/*",
                "~/Library/Application Support/CrashReporter/*"
            ],
            requiresElevatedAccess: false
        ),
        StorageCategory(
            id: "system-log-files",
            title: "System Log Files",
            iconName: "gearshape.2.fill",
            detail: "Removes macOS system log archives (requires permissions).",
            safety: .advanced,
            paths: [
                "/Library/Logs/*",
                "/private/var/log/*"
            ],
            requiresElevatedAccess: true
        ),
        StorageCategory(
            id: "language-files",
            title: "Language Files",
            iconName: "character.book.closed",
            detail: "Remove downloaded dictionaries and language models you do not use.",
            safety: .caution,
            paths: [
                "~/Library/Spelling/*",
                "~/Library/LanguageModeling/*",
                "/Library/Spelling/*"
            ],
            requiresElevatedAccess: true
        ),
        StorageCategory(
            id: "document-versions",
            title: "Document Versions",
            iconName: "clock.arrow.2.circlepath",
            detail: "Clears the .DocumentRevisions-V100 store of old document versions.",
            safety: .advanced,
            paths: ["~/.DocumentRevisions-V100/*"],
            requiresElevatedAccess: true
        ),
        StorageCategory(
            id: "login-items",
            title: "Broken Login Items",
            iconName: "exclamationmark.shield",
            detail: "Resets cached login/background items so macOS rebuilds them fresh.",
            safety: .caution,
            paths: [
                "~/Library/Application Support/com.apple.backgroundtaskmanagementagent/*",
                "~/Library/Preferences/com.apple.loginitems.plist"
            ],
            requiresElevatedAccess: false
        ),
        StorageCategory(
            id: "xcode-derived",
            title: "Xcode DerivedData",
            iconName: "hammer",
            detail: "Cleans Xcode's DerivedData folder (projects rebuild when needed).",
            safety: .caution,
            paths: ["~/Library/Developer/Xcode/DerivedData"],
            requiresElevatedAccess: false
        ),
        StorageCategory(
            id: "xcode-archives",
            title: "Old Xcode Archives",
            iconName: "shippingbox",
            detail: "Remove outdated .xcarchive bundles from the Archives folder.",
            safety: .caution,
            paths: ["~/Library/Developer/Xcode/Archives/*"],
            requiresElevatedAccess: false
        ),
        StorageCategory(
            id: "xcode-simulators",
            title: "Xcode Simulators Runtime",
            iconName: "iphone",
            detail: "Remove simulator runtimes and device data you no longer need.",
            safety: .caution,
            paths: [
                "~/Library/Developer/CoreSimulator/Profiles/Runtimes/*",
                "~/Library/Developer/CoreSimulator/Devices/*",
                "/Library/Developer/CoreSimulator/Profiles/Runtimes/*",
                "/Library/Developer/CoreSimulator/Devices/*"
            ],
            requiresElevatedAccess: true
        ),
        StorageCategory(
            id: "xcode-device-support",
            title: "Xcode Device Support",
            iconName: "square.stack.3d.up",
            detail: "Clears cached device support files for iOS/watchOS/tvOS devices.",
            safety: .caution,
            paths: [
                "~/Library/Developer/Xcode/iOS DeviceSupport/*",
                "~/Library/Developer/Xcode/watchOS DeviceSupport/*",
                "~/Library/Developer/Xcode/tvOS DeviceSupport/*"
            ],
            requiresElevatedAccess: false
        ),
        StorageCategory(
            id: "xcode-caches",
            title: "Xcode Caches",
            iconName: "memorychip",
            detail: "Removes Xcode symbol/index caches (they regenerate automatically).",
            safety: .caution,
            paths: [
                "~/Library/Caches/com.apple.dt.Xcode/*",
                "~/Library/Application Support/Developer/Shared/Xcode/*",
                "~/Library/Developer/CoreSimulator/Caches/*",
                "/Library/Developer/CoreSimulator/Caches/*"
            ],
            requiresElevatedAccess: true
        ),
        StorageCategory(
            id: "package-managers",
            title: "Package Manager Caches",
            iconName: "shippingbox.circle",
            detail: "Removes npm, Yarn, pnpm, and pip caches.",
            safety: .safe,
            paths: [
                "~/.npm",
                "~/.cache/pip",
                "~/.pnpm-store",
                "~/.yarn/cache",
                "~/Library/Caches/Yarn"
            ],
            requiresElevatedAccess: false
        ),
        StorageCategory(
            id: "homebrew",
            title: "Homebrew Cache",
            iconName: "leaf",
            detail: "Clear downloaded bottle/cache artifacts from Homebrew.",
            safety: .safe,
            paths: [
                "~/Library/Caches/Homebrew",
                "~/Library/Logs/Homebrew"
            ],
            requiresElevatedAccess: false
        )
    ]
}

struct StorageCategoryState: Identifiable, Sendable {
    let category: StorageCategory
    var estimatedBytes: UInt64?
    var isCleaning: Bool = false

    var id: StorageCategory.ID { category.id }

    var statusText: String {
        guard let estimatedBytes else {
            return "Scanning…"
        }
        if estimatedBytes == 0 {
            return "Clean"
        }
        return ByteFormat.shortString(bytes: estimatedBytes)
    }

    var canClean: Bool {
        guard let bytes = estimatedBytes else { return false }
        return bytes > 0 && !isCleaning
    }
}

struct CleanupResult: Sendable {
    let removedBytes: UInt64
    let removedItems: Int
    let failures: [String]
}

enum ByteFormat {
    private static func formatter(style: ByteCountFormatter.CountStyle) -> ByteCountFormatter {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        formatter.countStyle = style
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter
    }

    static func string(bytes: UInt64, style: ByteCountFormatter.CountStyle = .file) -> String {
        return formatter(style: style).string(fromByteCount: Int64(bytes))
    }

    static func shortString(bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .file
        formatter.isAdaptive = true
        formatter.includesUnit = true
        formatter.includesCount = true
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

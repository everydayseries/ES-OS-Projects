import Foundation
import SwiftUI

@MainActor
final class StorageViewModel: ObservableObject {
    @Published private(set) var diskUsage: DiskUsage = DiskUtility.fetchUsage()
    @Published var categories: [StorageCategoryState]
    @Published var toastMessage: String?
    @Published var isRefreshingCategories = false
    @Published var isBulkCleaning = false

    private let cleanupService = CleanupService()

    init(categories: [StorageCategory] = StorageCategory.presets) {
        self.categories = categories.map { StorageCategoryState(category: $0, estimatedBytes: nil) }
        refreshAll()
    }

    var menuLabel: String {
        guard diskUsage.totalBytes > 0 else { return "Storage" }
        return "\(ByteFormat.shortString(bytes: diskUsage.freeBytes)) free"
    }

    var menuIconName: String {
        diskUsage.freeFraction < 0.15 ? "internaldrive.trianglebadge.exclamationmark" : "internaldrive"
    }

    var isAnyCategoryCleaning: Bool {
        categories.contains { $0.isCleaning }
    }

    func openCategoryInTerminal(_ categoryID: StorageCategory.ID) {
        guard let category = categories.first(where: { $0.category.id == categoryID })?.category else {
            toastMessage = "Unable to determine path for \(categoryID)."
            return
        }

        let result = DiskUtility.openInTerminal(paths: category.paths)
        toastMessage = result ?? "Opened \(category.title) in Terminal."
    }

    func refreshAll() {
        toastMessage = nil
        diskUsage = DiskUtility.fetchUsage()
        refreshCategorySizes()
    }

    func refreshCategorySizes() {
        guard !isRefreshingCategories else { return }
        isRefreshingCategories = true

        let currentCategories = categories.map { $0.category }
        Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }
            var updates: [(StorageCategory.ID, UInt64?)] = []
            for category in currentCategories {
                let size = await self.cleanupService.estimateSize(for: category)
                updates.append((category.id, size))
            }

            await MainActor.run { [weak self] in
                guard let self = self else { return }
                for update in updates {
                    if let index = self.categories.firstIndex(where: { $0.category.id == update.0 }) {
                        self.categories[index].estimatedBytes = update.1
                    }
                }
                self.isRefreshingCategories = false
            }
        }
    }

    func cleanCategory(_ categoryID: StorageCategory.ID) {
        guard !isBulkCleaning,
              let index = categories.firstIndex(where: { $0.category.id == categoryID }) else {
            return
        }

        categories[index].isCleaning = true
        toastMessage = nil
        let category = categories[index].category

        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            let result = await self.cleanupService.clean(category: category)
            let remaining = await self.cleanupService.estimateSize(for: category)

            await MainActor.run { [weak self] in
                guard let self = self else { return }

                if let idx = self.categories.firstIndex(where: { $0.category.id == category.id }) {
                    self.categories[idx].isCleaning = false
                    self.categories[idx].estimatedBytes = remaining
                }

                self.diskUsage = DiskUtility.fetchUsage()
                self.toastMessage = self.message(for: category, result: result)
            }
        }
    }

    func cleanAllCategories() {
        guard !isBulkCleaning else { return }
        isBulkCleaning = true
        toastMessage = nil

        let selectedCategories = categories.map { $0.category }
        Task.detached(priority: .utility) { [weak self] in
            guard let self = self else { return }
            var totalBytes: UInt64 = 0
            var totalItems = 0
            var errors: [String] = []

            for category in selectedCategories {
                let result = await self.cleanupService.clean(category: category)
                totalBytes += result.removedBytes
                totalItems += result.removedItems
                errors.append(contentsOf: result.failures)
            }

            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.diskUsage = DiskUtility.fetchUsage()
                self.isBulkCleaning = false
                self.toastMessage = self.bulkMessage(bytes: totalBytes, items: totalItems, errors: errors)
                self.refreshCategorySizes()
            }
        }
    }

    private func message(for category: StorageCategory, result: CleanupResult) -> String {
        if result.removedBytes == 0 && result.failures.isEmpty {
            return "\(category.title): nothing to remove."
        }

        var message = "\(category.title): removed \(ByteFormat.shortString(bytes: result.removedBytes))."
        if !result.failures.isEmpty {
            message += " \(result.failures.count) item(s) skipped."
        }
        return message
    }

    private func bulkMessage(bytes: UInt64, items: Int, errors: [String]) -> String {
        if bytes == 0 {
            return "No additional files could be cleaned."
        }

        var message = "Cleared \(ByteFormat.shortString(bytes: bytes)) from \(items) item(s)."
        if !errors.isEmpty {
            message += " \(errors.count) path(s) skipped."
        }
        return message
    }
}

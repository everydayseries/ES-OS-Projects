import SwiftUI

struct StorageMenuView: View {
    @ObservedObject var viewModel: StorageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DiskSummaryView(usage: viewModel.diskUsage)

            Divider()

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.categories) { state in
                        StorageCategoryRow(
                            state: state,
                            disableActions: viewModel.isBulkCleaning
                        ,
                            cleanAction: {
                                viewModel.cleanCategory(state.category.id)
                            },
                            openAction: {
                                viewModel.openCategoryInTerminal(state.category.id)
                            }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(height: 320)

            Divider()

            HStack {
                Button {
                    viewModel.refreshAll()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(viewModel.isRefreshingCategories || viewModel.isBulkCleaning)

                Spacer()

                Button(role: .destructive) {
                    viewModel.cleanAllCategories()
                } label: {
                    Label("Clear All", systemImage: "sparkles")
                }
                .disabled(viewModel.isBulkCleaning || viewModel.isAnyCategoryCleaning)
            }

            if let message = viewModel.toastMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(width: 360)
    }
}

private struct DiskSummaryView: View {
    let usage: DiskUsage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Disk Overview")
                .font(.headline)

            ProgressView(value: usage.usedFraction) {
                HStack {
                    Text("Used \(ByteFormat.shortString(bytes: usage.usedBytes))")
                    Spacer()
                    Text("\(ByteFormat.shortString(bytes: usage.freeBytes)) free")
                }
                .font(.subheadline)
                .monospacedDigit()
            }

            Text("Total capacity \(ByteFormat.string(bytes: usage.totalBytes))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

private struct StorageCategoryRow: View {
    let state: StorageCategoryState
    let disableActions: Bool
    let cleanAction: () -> Void
    let openAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Label(state.category.title, systemImage: state.category.iconName)
                    .font(.headline)
                Spacer()
                Text(state.statusText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(state.category.detail)
                .font(.footnote)
                .foregroundColor(.secondary)

            HStack {
                SafetyBadge(level: state.category.safety)

                Spacer()

                if state.category.requiresElevatedAccess {
                    Button {
                        openAction()
                    } label: {
                        Label("Open in Terminal", systemImage: "terminal")
                    }
                    .buttonStyle(.bordered)
                    .help("Open this folder in Terminal so you can inspect or clean it manually.")
                } else if state.isCleaning {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Button(action: cleanAction) {
                        Label("Clean", systemImage: "broom")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!state.canClean || disableActions)
                }
            }
        }
        .padding(12)
        .background(.quaternary.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct SafetyBadge: View {
    let level: StorageCategory.SafetyLevel

    var body: some View {
        Text(level.rawValue.uppercased())
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(levelColor.opacity(0.15))
            .foregroundColor(levelColor)
            .clipShape(Capsule())
    }

    private var levelColor: Color {
        switch level {
        case .safe: return .green
        case .caution: return .orange
        case .advanced: return .red
        }
    }
}

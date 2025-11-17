import AppKit
import Combine
import SwiftUI

@main
struct StorageMenuApp {
    static func main() {
        let delegate = StorageStatusController()
        let app = NSApplication.shared
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}

@MainActor
final class StorageStatusController: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private let popover = NSPopover()
    private var eventMonitor: Any?
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel = StorageViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        applyApplicationIcon()
        configureStatusItem()
        configurePopover()
        observeViewModel()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
    }

    private func applyApplicationIcon() {
        if let iconURL = Bundle.module.url(forResource: "AppIcon", withExtension: "icns"),
           let image = NSImage(contentsOf: iconURL) {
            NSApp.applicationIconImage = image
        }
    }

    private func configureStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem?.button else { return }

        button.target = self
        button.action = #selector(togglePopover)
        button.imagePosition = .imageLeading
        button.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
        button.toolTip = "Storage Menu"
        statusItem?.isVisible = true
        updateStatusButton()
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 360, height: 420)
        popover.contentViewController = NSHostingController(
            rootView: StorageMenuView(viewModel: viewModel)
                .padding(.vertical)
                .padding(.horizontal, 12)
        )

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if self?.popover.isShown == true {
                self?.popover.performClose(nil)
            }
        }
    }

    private func observeViewModel() {
        viewModel.$diskUsage
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusButton()
            }
            .store(in: &cancellables)
    }

    private func updateStatusButton() {
        guard let button = statusItem?.button else { return }
        button.title = viewModel.menuLabel
        if let image = NSImage(
            systemSymbolName: viewModel.menuIconName,
            accessibilityDescription: "Storage"
        ) {
            image.isTemplate = true
            button.image = image
        } else {
            button.image = nil
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.becomeKey()
        }
    }
}

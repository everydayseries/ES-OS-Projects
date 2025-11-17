# mac-clean

A two-part toolkit for keeping macOS development machines lean:

1. **`mac_cleanup.sh`** — an interactive Bash script that previews and deletes caches, logs, build artifacts, orphaned directories, and other bulk storage culprits. It can target system temp files, browser caches, Node/Python/Flutter/iOS/Android build folders, Docker layers, IDE caches, Homebrew downloads, and more.
2. **StorageMenuApp** — a SwiftUI/Combine-powered menu bar app (see `dist/StorageMenuApp.app` or the `.dmg`) that constantly reports free disk space, estimates category sizes in the background, and lets you trigger targeted clean-ups right from the menu bar.

Both utilities are MIT-licensed and safe to remix into your own workflows.

## Quick start

### Command-line cleaner
```bash
cd mac-clean
chmod +x mac_cleanup.sh
./mac_cleanup.sh    # follow the prompts, or pass -f to skip confirmations
```
The script shows a preview (path + size) for each category before removing anything. Answer per-category or apply to all, and it keeps a running total of bytes reclaimed.

### Menu bar monitor
- Run `swift build` (Xcode 15+/Swift 5.9+) to compile from source, or generate a DMG with the steps below.
- A new status item appears showing remaining free space (e.g. “120 GB free”).
- Click it to see categorized storage usage, trigger one-tap cleanups, or open locations directly in Terminal when you prefer manual inspection.

## Rebuild the `.app` + `.dmg`
```bash
cd mac-clean
./scripts/package_dmg.sh
```
This script wipes `dist/`, builds a fresh `StorageMenuApp.app`, and packages a `StorageMenuApp.dmg`. The `dist/` directory is intentionally Git-ignored—regenerate artifacts locally whenever you need to redistribute the app.

## Folder guide
- `mac_cleanup.sh` — standalone Bash script with rich logging/colors.
- `Sources/` — SwiftUI app, including `CleanupService` and `DiskUtility` helpers shared by the script.
- `scripts/` — helper shell/Swift scripts used when packaging the app.
- `dist/` — signed binaries: `.app`, `.dmg`, and staging assets for release builds.
- `.swiftpm-cache`/`.build` — Swift Package Manager build outputs kept for reproducible builds.

## Submit requests or fixes
Need another category (e.g. Unity, Unreal, data-science caches)? File an issue or open a PR. Just stay mindful of the “no private paths” rule—use environment variables (`$HOME`, etc.) in contributions so the cleaner remains safe for everyone.

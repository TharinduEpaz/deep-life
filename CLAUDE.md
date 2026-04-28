# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**deeplife** is a macOS application (deployment target: macOS 15.7) built with SwiftUI and SwiftData. Bundle ID: `tedd.deeplife`. Currently in early development with a basic item management UI using NavigationSplitView with master-detail pattern.

## Build & Test Commands

Build and run via Xcode or command line:

```bash
# Build
xcodebuild -project deeplife.xcodeproj -scheme deeplife -configuration Debug build

# Run unit tests
xcodebuild -project deeplife.xcodeproj -scheme deeplife -configuration Debug test

# Run a specific test class
xcodebuild -project deeplife.xcodeproj -scheme deeplife -only-testing:deeplifeTests/deeplifeTests test

# Run UI tests
xcodebuild -project deeplife.xcodeproj -scheme deeplife -only-testing:deeplifeUITests test
```

## Architecture

- **SwiftUI + SwiftData** — no external dependencies, no package manager
- **Entry point:** `deeplife/deeplifeApp.swift` — sets up SwiftData ModelContainer with in-memory storage
- **Main view:** `deeplife/ContentView.swift` — NavigationSplitView with @Query-driven item list
- **Model:** `deeplife/Item.swift` — single @Model class with a `timestamp` property
- **State management:** SwiftUI's @Query and @Environment (no separate ViewModel layer)

## Key Configuration

- Swift 5.0, macOS 15.7 target
- Approachable concurrency enabled with MainActor default isolation
- App Sandbox enabled
- Three targets: `deeplife` (app), `deeplifeTests` (unit), `deeplifeUITests` (UI)

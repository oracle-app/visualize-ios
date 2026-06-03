# Visualize

Turn your data into stories worth sharing.

Visualize is an iOS app for creating, annotating and sharing data visualizations with your team. Generate charts from your own data, mark them up with the built-in snipping tool, post them to a feed, and have conversations around them with comments and threaded replies.

## Features

### Generate visualizations
Pick a dataset and let the app suggest the chart types that best fit your data. Tweak the configuration and create polished visualizations powered by SciChart.

### Personal feed
A home feed of your visualizations, your team's visualizations and everything shared with you. Search, filter, hide and delete from a single place.

### Snip & annotate
Open any chart full-screen and start drawing on top of it: circles, arrows, free-hand strokes and text annotations. Highlight exactly the part of the chart that matters and explain why it matters.

### Threads
Every visualization has its own conversation. Drop a comment, reply, and keep the discussion right next to the chart it's about, no more lost context in Slack DMs.

### Teams & sharing
Create teams, invite teammates and share visualizations with the people who need to see them. Granular control over who can view what.

### Auth flows
Sign up, login, password reset, all built on Firebase Auth.

## Architecture

The app follows a clean MVVM + Clean Architecture approach with three explicit layers:

```
presentation/   ← SwiftUI Views + ViewModels (the UI)
domain/         ← Models, Use Cases, Repository protocols (the rules)
data/           ← Repository implementations, DataSources, DTOs (the wiring)
```

* Views are dumb: they observe state and render.
* ViewModels call Use Cases, never repositories directly.
* Use Cases depend on repository protocols, never their implementations.
* DTOs stay in the data layer; the domain only knows about entities.

This makes the codebase easy to navigate, easy to test, and easy to swap data sources (Firebase today, anything else tomorrow).

## Project structure

```
visualize/
├── Presentation/
│   ├── Screens/
│   │   ├── Feed/                 → home feed, search, share with teammates
│   │   ├── FullScreen/           → chart viewer, snipping tool, threads
│   │   ├── GenerateVis/          → dataset upload, chart generation
│   │   ├── GenerateVisShare/     → share flow for new visualizations
│   │   ├── LandingScreen/        → first-launch entry point
│   │   ├── Login/ · SignUp/      → auth screens
│   │   ├── ResetPassword/        → password recovery
│   │   ├── ProfileScreen/        → user profile
│   │   └── VizReady/             → "your chart is ready" confirmation
│   ├── Components/               → shared UI (Navbar, Tabs, Auth fields…)
│   └── Colors.swift              → design tokens
│
├── Domain/
│   ├── Models/                   → AppUser, VisualizationCard, Comment, Team…
│   ├── UseCases/                 → one operation per file
│   └── Repositories/             → protocols only
│
└── Data/
    ├── Repositories/             → Firebase-backed implementations
    ├── DataSources/              → API services
    ├── DTOs/                     → server-shape models
    └── Mappers/                  → DTO ↔ Entity translation
```

## Tech stack

| Layer | Tools |
|---|---|
| UI | SwiftUI, `@Observable`, `@FocusState`, `glassEffect` |
| Charts | [SciChart for iOS](https://www.scichart.com/) |
| Backend | Firebase (Auth, Firestore, Storage, App Check) |
| Language | Swift 5 |
| Min target | iOS 26 |
| Linting | SwiftLint |

## Getting started

### Requirements
* macOS with Xcode 26 or later
* An iOS 26+ simulator or device
* A Firebase project with `GoogleService-Info.plist`
* A valid SciChart license key

### Setup

1. **Clone the repo**
   ```bash
   git clone <your-repo-url>
   cd visualize-ios
   ```

2. **Add your Firebase config**
   Drop your `GoogleService-Info.plist` inside `visualize/` (it's gitignored on purpose).

3. **Add your SciChart license**
   Open `Config.xcconfig` and set:
   ```
   SCICHART_LICENSE_KEY = your-license-key-here
   ```

4. **Open the project**
   ```bash
   open visualize.xcodeproj
   ```

5. **Build & run**, Cmd + R.

Swift Package Manager will resolve Firebase and SciChart on the first build.

## Design

Visualize has its own design system. All colors live in `Presentation/Colors.swift` as tokens (`appNavy`, `appTeal`, `appLightTeal`, `primaryOrange`, etc.), so anything you build stays consistent with the rest of the app. Buttons use a custom `glassEffect` treatment for the soft, depth-rich feel you see throughout the screens.

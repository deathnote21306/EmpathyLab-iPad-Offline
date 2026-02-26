# EmpathyLab iPad App Instructions

This Swift project is an iPad‑focused SwiftUI application built as a Swift
Package. The codebase is intentionally small; most of the real behaviour lives
in feature folders that start out empty (`.gitkeep` files are used so Git
tracks them). If you're an AI agent joining the repo, here's what to know to
get productive quickly.

## Big Picture

* **Single package**: `EmpathyLab.swiftpm` defines one executable target,
  `EmpathyLabApp`. There are no external dependencies at the moment.
* **Entry point**: `Sources/EmpathyLabApp/EmpathyLabApp.swift` declares the
  `@main` struct and launches `AppRootView` (currently a stub).
* **UI layout**: the app is expected to use SwiftUI `NavigationStack`/`TabView`
  within `AppRootView` to switch between feature screens. Update that file
  when adding the first real navigation logic.
* **Directory conventions** under
  `Sources/EmpathyLabApp/`:
  * `App/` – shared root views and high–level containers.
  * `Components/` – reusable SwiftUI components.
  * `Effects/` – animations, haptics, other visual effects.
  * `Features/` – each feature gets its own subfolder (e.g. `Home`, `Lab`,
    `Results`). Put views, view models, and feature‑specific helpers here.
  * `Models/` – plain data types, codable structs, etc.
  * `Services/` – business logic, networking or data providers, helpers.
  * `Style/` – colour palettes, font definitions, theming helpers.

  Most feature folders currently contain only a `.gitkeep`; when you add a
  Swift file the directory can be removed from `.gitignore` if applicable.

* **Resources**: static assets live in the top‑level `Resources/` directory
  (Audio/, Images/, `profiles.json`, `scenarios.json`). The package manifest
  processes this folder (`.process("../../Resources")`). JSON files are
  loaded at runtime; their top‑level structure is:
  ```json
  { "profiles": [ /* profile objects */ ] }
  { "scenarios": [ /* scenario objects */ ] }
  ```
  Modify them directly when adding new test data.

## Build / Run / Debug

1. **Xcode** – open the `EmpathyLab.swiftpm` package, select the
   `EmpathyLabApp` scheme, then run on Simulator or a connected iPad. This is
   the usual workflow for development and manual testing.
2. **CLI** – from the workspace root:
   ```sh
   cd EmpathyLab.swiftpm
   swift build            # compiles the package
   # swift run EmpathyLabApp # only useful on macOS; use Xcode for iOS targets
   ```
   Use `swift package clean` if builds become stale after adding resources.
3. **Adding assets** – drop new files in `Resources/Audio` or
   `Resources/Images`. SwiftPM will bundle them automatically. Refer to them
   with `Bundle.module` in code.
4. **Editing JSON** – the runtime loader expects `profiles.json` and
   `scenarios.json` at top level; keep their keys intact.
5. **Device provisioning** – standard Xcode provisioning rules apply; this
   repo is intended to run offline on an iPad, so be mindful of entitlements
   if you add features needing network access later.

## Code Conventions

* Follow SwiftUI and MVVM patterns. A typical feature defines `FooView.swift`
  and `FooViewModel.swift` (both inside the feature folder). View models are
  `ObservableObject`s annotated with `@MainActor`.
* Use descriptive, camel‑cased names that mirror the folder structure. e.g.
  `LabStepView` lives in `Features/Lab/`.
* No package dependencies yet; when you add one, update `Package.swift` and run
  `swift package update`. Keep all code inside `Sources/EmpathyLabApp`.
* Avoid hard‑coded file paths; use `Bundle.module` or `FileManager` relative to
  the app bundle for resource lookup.
* Use `.gitkeep` to keep empty directories; remove it once the directory gets
  real code.
* There are currently no automated tests. Add new test targets in
  `Package.swift` if you create unit or UI tests later.

## Patterns & Integration

* Routing/navigation is handled centrally in `AppRootView` (or whatever view
  replaces it). When adding a new feature, register its entry point there.
* Feature code seldom crosses boundaries; if two features need to share data,
  place the shared model in `Models/` and inject via environment objects or
  explicit initialisers.
* Services are simple Swift types; they may be singletons or passed through
  initialisers depending on use. There is no dependency injection framework.
* Resources are static and loaded synchronously; asynchronous loading is not
  currently required.

## Examples

* See `AppRootView.swift` for the minimal launch view; extend it with
  `NavigationStack { HomeView() }` etc.
* `Package.swift` shows how resources are processed and how the executable
  target is declared.

---

Feel free to ask if any part of the structure or workflow isn’t clear; I can
iterate on these instructions with concrete examples.
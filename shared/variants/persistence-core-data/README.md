# Core Data variant

When you scaffold with `--persistence core-data`, the CLI swaps `CoreDataController.swift` in for `PersistenceController.swift` (the SwiftData default). Both live in `Modules/Core/CorePersistence/Sources/` for the Tuist Clean+MVVM+Repository template, and inside `Modules/Package.swift`'s `CorePersistence` target for XcodeGen.

## What's the same

- Both expose a `@MainActor` controller with a `viewContext`-like surface
- Both throw on failure (no `fatalError`)
- Both are imported by feature `Data/` layers, not `Domain/` or `Presentation/`

## What's different

| Aspect | SwiftData (default) | Core Data |
|--------|---------------------|-----------|
| Model definition | `@Model` Swift classes | `.xcdatamodeld` editor + `NSManagedObject` subclasses |
| Schema | inferred at runtime | declared in the bundle |
| Concurrency | `@ModelActor` | `NSManagedObjectContext.perform { … }` |
| Min iOS | 17 | 13 |
| Migration | mostly automatic | lightweight + custom mappings |
| CloudKit sync | `ModelConfiguration.cloudKitContainerIdentifier` | `NSPersistentCloudKitContainer` |

## When to pick which

- **SwiftData** if you're greenfield, iOS 17+, and want less ceremony.
- **Core Data** if you have an existing CloudKit/CoreData schema, need to support iOS 16 or older, or you have engineers who already know Core Data well.

## After scaffolding with Core Data

1. Add a `<YourModel>.xcdatamodeld` bundle. In Xcode: **File → New → File → Data Model**.
2. Reference its name in `AppComposer.swift`:
   ```swift
   persistence = try CoreDataController(modelName: "<YourModel>")
   ```
3. Define `NSManagedObject` subclasses (or use Xcode's "Class Definition" codegen option in the model editor).

## Migrating between the two later

You generally can't auto-migrate from SwiftData to Core Data or vice versa — they use the same underlying SQLite format but the schemas differ. Plan a one-time migration script if you need to switch after launch.

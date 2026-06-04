//
//  CoreDataController.swift
//  CorePersistence
//
//  Drop-in Core Data alternative to the SwiftData PersistenceController.
//  Used when the project is scaffolded with `--persistence core-data`.
//
//  Note: you must also add a `<YourModel>.xcdatamodeld` bundle to your app's
//  Resources and reference its name below.
//

import AppCore
import CoreData
import Foundation

@MainActor
public final class CoreDataController {
  public let container: NSPersistentContainer

  /// Initialize the Core Data stack.
  /// - Parameters:
  ///   - modelName: name of the `.xcdatamodeld` bundle (without extension)
  ///   - inMemory: use an in-memory store (for tests/previews)
  public init(modelName: String, inMemory: Bool = false) throws {
    container = NSPersistentContainer(name: modelName)

    if inMemory, let firstDescription = container.persistentStoreDescriptions.first {
      firstDescription.url = URL(filePath: "/dev/null")
    }

    var loadError: Error?
    container.loadPersistentStores { _, error in
      if let error {
        loadError = error
      }
    }

    if let loadError {
      AppLogger.data.error("Core Data store failed to load: \(loadError.localizedDescription)")
      throw AppError.unknown(underlying: "Persistence init failed: \(loadError.localizedDescription)")
    }

    container.viewContext.automaticallyMergesChangesFromParent = true
  }

  public var viewContext: NSManagedObjectContext { container.viewContext }

  public func newBackgroundContext() -> NSManagedObjectContext {
    container.newBackgroundContext()
  }

  public func save() throws {
    let context = viewContext
    guard context.hasChanges else { return }
    do {
      try context.save()
    } catch {
      AppLogger.data.error("Core Data save failed: \(error.localizedDescription)")
      throw AppError.unknown(underlying: "Save failed: \(error.localizedDescription)")
    }
  }
}

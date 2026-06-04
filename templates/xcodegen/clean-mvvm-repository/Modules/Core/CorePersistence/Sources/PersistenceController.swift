//
//  PersistenceController.swift
//  CorePersistence
//

import AppCore
import Foundation
import SwiftData

@MainActor
public final class PersistenceController {
  public let container: ModelContainer

  public init(inMemory: Bool = false, models: [any PersistentModel.Type] = []) throws {
    let schema = Schema(models)
    let config = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: inMemory
    )
    do {
      container = try ModelContainer(for: schema, configurations: [config])
    } catch {
      AppLogger.data.error("Failed to create ModelContainer: \(error.localizedDescription)")
      throw AppError.unknown(underlying: "Persistence init failed: \(error.localizedDescription)")
    }
  }
}

//
//  AppLogger.swift
//  AppCore
//

import Foundation
import OSLog

public enum AppLogger {
  public static let app = Logger(subsystem: "__BUNDLE_ID__", category: "app")
  public static let domain = Logger(subsystem: "__BUNDLE_ID__", category: "domain")
  public static let data = Logger(subsystem: "__BUNDLE_ID__", category: "data")
  public static let ui = Logger(subsystem: "__BUNDLE_ID__", category: "ui")
  public static let network = Logger(subsystem: "__BUNDLE_ID__", category: "network")
}

public enum AppError: LocalizedError, Sendable {
  case network(underlying: String)
  case decoding(underlying: String)
  case notFound
  case unauthorized
  case unknown(underlying: String)

  public var errorDescription: String? {
    switch self {
    case .network(let msg): "Network error: \(msg)"
    case .decoding(let msg): "Decoding error: \(msg)"
    case .notFound: "Not found"
    case .unauthorized: "Unauthorized"
    case .unknown(let msg): "Unknown: \(msg)"
    }
  }
}

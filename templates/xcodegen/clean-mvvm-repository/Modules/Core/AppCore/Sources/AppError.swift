//
//  AppError.swift
//  AppCore
//

import Foundation

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
    case .unknown(let msg): "Unknown error: \(msg)"
    }
  }
}

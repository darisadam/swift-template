//
//  AppLogger.swift
//  __APP_NAME__
//

import Foundation
import OSLog

enum AppLogger {
  static let app = Logger(subsystem: "__BUNDLE_ID__", category: "app")
  static let ui = Logger(subsystem: "__BUNDLE_ID__", category: "ui")
  static let network = Logger(subsystem: "__BUNDLE_ID__", category: "network")
}

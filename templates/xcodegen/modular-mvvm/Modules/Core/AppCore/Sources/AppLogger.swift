//
//  AppLogger.swift
//  AppCore
//

import Foundation
import OSLog

public enum AppLogger {
  public static let app = Logger(subsystem: "__BUNDLE_ID__", category: "app")
  public static let ui = Logger(subsystem: "__BUNDLE_ID__", category: "ui")
  public static let network = Logger(subsystem: "__BUNDLE_ID__", category: "network")
}

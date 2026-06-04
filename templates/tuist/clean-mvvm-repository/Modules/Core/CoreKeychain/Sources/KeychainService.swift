//
//  KeychainService.swift
//  CoreKeychain
//

import AppCore
import Foundation
import Security

public protocol KeychainServiceProtocol: Sendable {
  func set(_ value: String, for key: String) throws
  func get(_ key: String) throws -> String?
  func delete(_ key: String) throws
}

public actor KeychainService: KeychainServiceProtocol {
  private let service: String

  public init(service: String = "__BUNDLE_ID__") {
    self.service = service
  }

  public func set(_ value: String, for key: String) throws {
    guard let data = value.data(using: .utf8) else {
      throw AppError.unknown(underlying: "Encoding failed")
    }
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key
    ]
    SecItemDelete(query as CFDictionary)
    var attrs = query
    attrs[kSecValueData as String] = data
    attrs[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
    let status = SecItemAdd(attrs as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw AppError.unknown(underlying: "Keychain set failed: \(status)")
    }
  }

  public func get(_ key: String) throws -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    switch status {
    case errSecSuccess:
      guard let data = result as? Data else { return nil }
      return String(data: data, encoding: .utf8)
    case errSecItemNotFound: return nil
    default: throw AppError.unknown(underlying: "Keychain get failed: \(status)")
    }
  }

  public func delete(_ key: String) throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key
    ]
    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw AppError.unknown(underlying: "Keychain delete failed: \(status)")
    }
  }
}

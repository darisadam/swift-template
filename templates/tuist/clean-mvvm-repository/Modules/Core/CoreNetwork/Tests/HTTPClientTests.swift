//
//  HTTPClientTests.swift
//  CoreNetworkTests
//

@testable import CoreNetwork
import XCTest

final class HTTPClientTests: XCTestCase {
  func testInit_succeeds() {
    let url = URL(string: "https://example.com") ?? URL(filePath: "/")
    _ = HTTPClient(baseURL: url)
  }
}

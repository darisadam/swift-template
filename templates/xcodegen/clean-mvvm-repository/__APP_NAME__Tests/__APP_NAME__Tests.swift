//
//  __APP_NAME__Tests.swift
//  __APP_NAME__Tests
//

@testable import __APP_NAME__
import XCTest

@MainActor
final class __APP_NAME__Tests: XCTestCase {
  func testComposer_buildsHomeViewModel() {
    let composer = AppComposer()
    _ = composer.makeHomeViewModel()
  }

  func testComposer_buildsProfileViewModel() {
    let composer = AppComposer()
    _ = composer.makeProfileViewModel()
  }
}

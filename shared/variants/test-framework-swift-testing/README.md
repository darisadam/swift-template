# Swift Testing variants

Files in this directory are alternates that the CLI swaps in when `--test-framework swift-testing` is passed.

## Why a separate variant directory?

The default test framework is **XCTest** because it's universally supported (every Xcode version, every CI provider, every Swift version). When `--test-framework swift-testing` is passed, the CLI overlays these files into the generated project's test target, replacing the XCTest version.

## What changes

| File | XCTest | Swift Testing |
|------|--------|---------------|
| `import` | `import XCTest` | `import Testing` |
| Test class | `final class FooTests: XCTestCase` | `struct FooTests` |
| Test method | `func testFoo()` | `@Test func foo()` |
| Assertion | `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| Setup | `override func setUp()` | `init()` / `@Test(arguments:)` |
| Async | `func testFoo() async` | `@Test func foo() async` |
| Parametrized | duplicate `func testFooA/B/C` | `@Test(arguments: [...])` |

Swift Testing is the recommended modern choice when:
- You're on Swift 6 (which all templates default to)
- Your CI uses Xcode 16+ (Swift Testing is bundled)
- You like value-typed tests, parametrized tests, expressive `#expect` failures

## Templates that have Swift Testing variants

- `xcodegen/simple-mvvm` — `CounterViewModelTests.swift`
- `tuist/simple-mvvm` — `CounterViewModelTests.swift`

For modular templates (`modular-mvvm`, `clean-mvvm-repository`, `modular-tca`), pick `--test-framework xctest` for now — Swift Testing variants for module-level tests will follow.

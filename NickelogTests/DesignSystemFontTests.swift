import XCTest
import UIKit
@testable import Nickelog

/// A wrong font name silently falls back to the system font, so check that every
/// font the design system asks for is really bundled and registered.
final class DesignSystemFontTests: XCTestCase {
    func testEveryTypeStyleFontLoads() {
        for style in AppTextStyle.allCases {
            guard let name = style.fontName else { continue }
            XCTAssertNotNil(UIFont(name: name, size: 20), "\(name) did not load for \(style)")
        }
    }

    func testCustomFontStylesHaveASize() {
        for style in AppTextStyle.allCases where style.fontName != nil {
            XCTAssertGreaterThan(style.baseSize, 0, "\(style) needs a base size")
        }
    }
}

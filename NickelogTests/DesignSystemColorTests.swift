import XCTest
import UIKit
@testable import Nickelog

/// A typo in a color asset name renders as clear, not as an error, so check them.
final class DesignSystemColorTests: XCTestCase {
    func testEveryColorTokenResolves() {
        for name in AppColor.allAssetNames {
            XCTAssertNotNil(UIColor(named: name), "\(name) is missing from the asset catalog")
        }
    }

    func testRedAndGroundMatchTheDesign() throws {
        let light = UITraitCollection(userInterfaceStyle: .light)
        func hex(_ name: String) throws -> String {
            let color = try XCTUnwrap(UIColor(named: name, in: .main, compatibleWith: light))
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            return String(format: "%02X%02X%02X", Int((r * 255).rounded()), Int((g * 255).rounded()), Int((b * 255).rounded()))
        }
        XCTAssertEqual(try hex("Ground"), "F3EDE2")
        XCTAssertEqual(try hex("Red"), "A2262F")
        XCTAssertEqual(try hex("Ink"), "2A1C14")
    }
}

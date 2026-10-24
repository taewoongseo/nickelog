import SwiftUI
import UIKit

/// Colors and type for one ticket design. Sizes are in points at the 1300x640
/// reference scale; the card multiplies them by its own scale factor.
/// Values come from `Design/ticket-and-logo/handoff.md` and the final ticket
/// section (6a, 6b, 6c) of `ticket-concepts.html`.
struct TicketTheme {
    struct TextStyle {
        let fontName: String
        let size: CGFloat
        var tracking: CGFloat = 0
        /// CSS-style line height as a multiple of the font size (used for wrapped text).
        var lineHeight: CGFloat = 1.0

        func font(scale: CGFloat) -> Font {
            .custom(fontName, fixedSize: size * scale)
        }

        /// Extra spacing between wrapped lines so the line box matches `lineHeight`.
        func lineSpacing(scale: CGFloat) -> CGFloat {
            let natural = UIFont(name: fontName, size: size * scale)?.lineHeight ?? size * scale
            return size * scale * lineHeight - natural
        }
    }

    let paper: Color
    let ink: Color
    /// Color of the date, location, and review text.
    let inkSecondary: Color
    let accent: Color
    let ruleSecondary: Color
    let serial: Color
    let ornament: Color

    let title: TextStyle
    let year: TextStyle
    let meta: TextStyle
    let review: TextStyle
    let admitOne: TextStyle
    let serialNumber: TextStyle
    let price: TextStyle
    let wordmark: TextStyle

    /// Every font name this theme uses, so tests can check none fall back silently.
    var fontNames: [String] {
        [title, year, meta, review, admitOne, serialNumber, price, wordmark].map(\.fontName)
    }

    static func theme(for design: TicketDesign) -> TicketTheme {
        switch design {
        case .grindhouseGothic: .grindhouseGothic
        case .marqueePrestige: .marqueePrestige
        case .sectorBlue: .sectorBlue
        }
    }

    private static let wordmarkStyle = TextStyle(fontName: "CourierPrime-Bold", size: 26, tracking: 3)

    /// 6a: burgundy and cream.
    static let grindhouseGothic = TicketTheme(
        paper: Color(hex: 0xF4EAD9),
        ink: Color(hex: 0x2B1512),
        inkSecondary: Color(hex: 0x3A241E),
        accent: Color(hex: 0x7A1F2B),
        ruleSecondary: Color(hex: 0xC8A97E),
        serial: Color(hex: 0xA2262F),
        ornament: Color(hex: 0xA2262F),
        title: TextStyle(fontName: "AbrilFatface-Regular", size: 76, lineHeight: 1.05),
        year: TextStyle(fontName: "CourierPrime-Bold", size: 40, tracking: 3),
        meta: TextStyle(fontName: "CourierPrime-Bold", size: 36),
        review: TextStyle(fontName: "OldStandardTT-Italic", size: 40, lineHeight: 1.42),
        admitOne: TextStyle(fontName: "Anton-Regular", size: 54, tracking: 7),
        serialNumber: TextStyle(fontName: "CourierPrime-Bold", size: 38, tracking: 1),
        price: TextStyle(fontName: "AbrilFatface-Regular", size: 44),
        wordmark: wordmarkStyle
    )

    /// 6b: amber and ivory.
    static let marqueePrestige = TicketTheme(
        paper: Color(hex: 0xF2E6CC),
        ink: Color(hex: 0x3A1F0A),
        inkSecondary: Color(hex: 0x3A1F0A),
        accent: Color(hex: 0xB5651D),
        ruleSecondary: Color(hex: 0xD9A15C),
        serial: Color(hex: 0xA8390F),
        ornament: Color(hex: 0xA8390F),
        title: TextStyle(fontName: "Limelight-Regular", size: 80, lineHeight: 1.1),
        year: TextStyle(fontName: "BodoniModa-Regular_Bold", size: 38, tracking: 2),
        meta: TextStyle(fontName: "SpecialElite-Regular", size: 34),
        review: TextStyle(fontName: "CormorantGaramond-Italic", size: 44, lineHeight: 1.4),
        admitOne: TextStyle(fontName: "BodoniModa-Regular_Black", size: 40, tracking: 5),
        serialNumber: TextStyle(fontName: "SpecialElite-Regular", size: 36, tracking: 1),
        price: TextStyle(fontName: "BodoniModa-Regular_Bold", size: 44),
        wordmark: wordmarkStyle
    )

    /// 6c: pastel blue.
    static let sectorBlue = TicketTheme(
        paper: Color(hex: 0xD9E6E9),
        ink: Color(hex: 0x1F3A4A),
        inkSecondary: Color(hex: 0x1F3A4A),
        accent: Color(hex: 0x2F5568),
        ruleSecondary: Color(hex: 0x7FA3AE),
        serial: Color(hex: 0xB2352A),
        ornament: Color(hex: 0x3D6B7A),
        title: TextStyle(fontName: "RozhaOne-Regular", size: 66, lineHeight: 1.1),
        year: TextStyle(fontName: "CourierPrime-Bold", size: 36, tracking: 2),
        meta: TextStyle(fontName: "CourierPrime-Bold", size: 34),
        review: TextStyle(fontName: "EBGaramond-SemiBoldItalic", size: 40, lineHeight: 1.42),
        admitOne: TextStyle(fontName: "Oswald-Regular_Bold", size: 52, tracking: 6),
        serialNumber: TextStyle(fontName: "CourierPrime-Bold", size: 38, tracking: 1),
        price: TextStyle(fontName: "RozhaOne-Regular", size: 42),
        wordmark: wordmarkStyle
    )
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

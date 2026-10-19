import SwiftUI

/// The named type styles from `Design/screens/handoff.md`. Apply with
/// `.appStyle(.label)`. Color is chosen separately with `AppColor`.
///
/// Every style scales with Dynamic Type. The caps labels, tab labels, and counters
/// stop growing at `xxxLarge` because they sit in layouts that can't reflow.
/// (Ticket text is separate: it uses fixed sizes and never scales.)
enum AppTextStyle: CaseIterable {
    case largeTitle, filmTitle, display
    case label, labelSmall
    case body, bodyStrong, bodyStrongSmall, callout, secondary
    case counter, tab
    case serial, slipEntry, slipReview
    case imprint, filmYear

    /// Bundled font name, or `nil` for styles set in the system font (SF).
    var fontName: String? {
        switch self {
        case .largeTitle, .filmTitle: "BodoniModa-Regular_Bold"
        case .display, .filmYear: "BodoniModa-Italic_Medium-Italic"
        case .label, .labelSmall: "Oswald-Regular_Medium"
        case .serial, .slipEntry: "CourierPrime-Bold"
        case .slipReview: "OldStandardTT-Italic"
        case .imprint: "Limelight-Regular"
        case .body, .bodyStrong, .bodyStrongSmall, .callout, .secondary, .counter, .tab: nil
        }
    }

    /// Design size in points at the default Dynamic Type setting.
    var baseSize: CGFloat {
        switch self {
        case .largeTitle: 32
        case .filmTitle: 36
        case .display: 26
        case .label: 12
        case .labelSmall: 11
        case .serial: 14
        case .slipEntry: 15
        case .slipReview: 17
        case .imprint: 13
        case .filmYear: 18
        case .body, .bodyStrong, .bodyStrongSmall, .callout, .secondary, .counter, .tab: 0
        }
    }

    /// Letter-spacing in em (a fraction of the font size).
    var trackingEm: CGFloat {
        switch self {
        case .largeTitle, .filmTitle: -0.01
        case .label: 0.16
        case .imprint: 0.12
        case .labelSmall: 0.2
        case .serial: 0.08
        default: 0
        }
    }

    var isUppercase: Bool {
        self == .label || self == .labelSmall
    }

    /// The system text style this style scales with.
    var relativeTo: Font.TextStyle {
        switch self {
        case .largeTitle, .filmTitle: .largeTitle
        case .display: .title
        case .label: .caption
        case .labelSmall, .tab: .caption2
        case .body, .bodyStrong: .body
        case .secondary, .bodyStrongSmall: .subheadline
        case .callout: .callout
        case .counter: .caption
        case .serial: .footnote
        case .slipEntry: .subheadline
        case .slipReview: .body
        case .imprint: .footnote
        case .filmYear: .title3
        }
    }

    /// Largest Dynamic Type size this style grows to.
    var maxDynamicTypeSize: DynamicTypeSize {
        switch self {
        case .label, .labelSmall, .tab, .counter, .imprint: .xxxLarge
        default: .accessibility5
        }
    }

    var font: Font {
        if let fontName {
            return .custom(fontName, size: baseSize, relativeTo: relativeTo)
        }
        switch self {
        case .bodyStrong: return .body.weight(.semibold)
        case .bodyStrongSmall: return .subheadline.weight(.semibold)
        case .callout: return .callout
        case .secondary: return .subheadline
        case .counter: return .caption.monospacedDigit()
        case .tab: return .caption2.weight(.semibold)
        default: return .body
        }
    }
}

private struct AppTextStyleModifier: ViewModifier {
    let style: AppTextStyle
    @ScaledMetric private var scale: CGFloat

    init(style: AppTextStyle) {
        self.style = style
        _scale = ScaledMetric(wrappedValue: 1, relativeTo: style.relativeTo)
    }

    func body(content: Content) -> some View {
        content
            .font(style.font)
            .tracking(style.trackingEm * style.baseSize * scale)
            .textCase(style.isUppercase ? .uppercase : nil)
            .dynamicTypeSize(...style.maxDynamicTypeSize)
    }
}

extension View {
    func appStyle(_ style: AppTextStyle) -> some View {
        modifier(AppTextStyleModifier(style: style))
    }
}

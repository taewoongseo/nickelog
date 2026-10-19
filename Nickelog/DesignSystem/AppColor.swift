import SwiftUI

/// The neutral "chrome" palette used by every screen outside the ticket.
/// Values live in `Assets.xcassets/Colors`; to add dark mode later, give each
/// color set a dark appearance there. No code here needs to change.
/// Ticket colors are separate (`TicketTheme`) and never follow these.
enum AppColor {
    static let ground = Color("Ground")
    static let surface = Color("Surface")
    static let ink = Color("Ink")
    static let ink2 = Color("Ink2")
    static let muted = Color("Muted")
    static let mutedSlip = Color("MutedSlip")
    static let hairline = Color("Hairline")
    static let hairlineSoft = Color("HairlineSoft")
    static let divider = Color("Divider")
    static let tan = Color("Tan")
    static let red = Color("Red")

    /// Asset names, so tests can check every token resolves.
    static let allAssetNames = [
        "Ground", "Surface", "Ink", "Ink2", "Muted", "MutedSlip",
        "Hairline", "HairlineSoft", "Divider", "Tan", "Red",
    ]
}

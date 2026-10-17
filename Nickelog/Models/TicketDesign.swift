import Foundation

/// The three ticket designs a user can choose from (see `Design/ticket-and-logo/handoff.md`).
/// The raw value is what gets stored in `Ticket.templateID`.
enum TicketDesign: String, CaseIterable, Codable, Identifiable {
    case grindhouseGothic = "grindhouse-gothic"
    case marqueePrestige = "marquee-prestige"
    case sectorBlue = "sector-blue"

    static let `default`: TicketDesign = .grindhouseGothic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .grindhouseGothic: "Grindhouse Gothic"
        case .marqueePrestige: "Marquee Prestige"
        case .sectorBlue: "Sector Blue"
        }
    }
}

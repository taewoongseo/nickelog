import SwiftUI

/// The caps row above a month's tickets: the month on the left, and either the open
/// ticket's position ("2 of 4") or a plain count ("4 tickets") on the right.
struct MonthHeaderRow: View {
    let title: String
    let trailing: String

    var body: some View {
        HStack {
            Text(title)
            Spacer(minLength: 12)
            Text(trailing)
        }
        .appStyle(.labelSmall)
        .foregroundStyle(AppColor.ink2)
        .padding(.horizontal, 2)
        .padding(.bottom, 8)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview("Month header") {
    VStack(spacing: 16) {
        MonthHeaderRow(title: "October 2026", trailing: "2 of 4")
        MonthHeaderRow(title: "September 2026", trailing: "4 tickets")
    }
    .padding(16)
    .background(AppColor.ground)
}

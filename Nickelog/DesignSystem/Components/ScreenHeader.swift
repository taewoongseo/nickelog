import SwiftUI

/// Large screen title (Bodoni), an optional caps caption underneath, and optional
/// trailing buttons, on a 52pt-tall title row with 16pt side margins.
struct ScreenHeader<Trailing: View>: View {
    let title: String
    var caption: String?
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 12) {
                Text(title)
                    .appStyle(.largeTitle)
                    .foregroundStyle(AppColor.ink)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 0)

                trailing()
            }
            .frame(minHeight: 52)

            if let caption {
                Text(caption)
                    .appStyle(.label)
                    .foregroundStyle(AppColor.ink2)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension ScreenHeader where Trailing == EmptyView {
    init(title: String, caption: String? = nil) {
        self.init(title: title, caption: caption, trailing: { EmptyView() })
    }
}

#Preview("Screen header") {
    VStack(spacing: 24) {
        ScreenHeader(title: "Ticket Book", caption: "112 tickets") {
            IconButton(systemName: "magnifyingglass", accessibilityLabel: "Search", action: {})
            IconButton(systemName: "person", accessibilityLabel: "Account", action: {})
        }
        ScreenHeader(title: "Log a Movie", caption: "What did you see?")
    }
    .background(AppColor.ground)
}

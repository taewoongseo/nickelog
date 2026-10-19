import SwiftUI

/// Small brand line: NICKELOG, a red star, ADMIT ONE. Used on quiet surfaces such
/// as the empty Collection.
struct BrandImprint: View {
    var body: some View {
        HStack(spacing: 8) {
            Text("NICKELOG")
                .appStyle(.imprint)

            Image(systemName: "star.fill")
                .font(.system(size: 9))
                .foregroundStyle(AppColor.red)
                .accessibilityHidden(true)

            Text("Admit One")
                .appStyle(.labelSmall)
        }
        .foregroundStyle(AppColor.muted)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Nickelog, Admit One")
    }
}

#Preview("Brand imprint") {
    BrandImprint()
        .padding(24)
        .background(AppColor.ground)
}

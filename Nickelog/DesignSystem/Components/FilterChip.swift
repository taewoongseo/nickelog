import SwiftUI

/// 34pt capsule chip. Selected: ink fill with light text. Unselected: surface fill
/// with a hairline border.
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    /// 14pt, scaling with Dynamic Type.
    @ScaledMetric(relativeTo: .footnote) private var fontSize: CGFloat = 14

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: fontSize, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? AppColor.surface : AppColor.ink)
                .padding(.horizontal, 14)
                .frame(minHeight: 34)
                .background(isSelected ? AppColor.ink : AppColor.surface, in: Capsule())
                .overlay(Capsule().strokeBorder(isSelected ? AppColor.ink : AppColor.hairline, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Chips") {
    HStack {
        FilterChip(title: "All years", isSelected: true, action: {})
        FilterChip(title: "2026", isSelected: false, action: {})
        FilterChip(title: "2025", isSelected: false, action: {})
    }
    .padding(16)
    .background(AppColor.ground)
}

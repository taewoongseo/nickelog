import SwiftUI

/// The top of the Log It and planning forms: a red caps label, the film's title, and its year.
struct FormFilmHeader: View {
    let label: String
    let title: String
    let year: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .appStyle(.label)
                .foregroundStyle(AppColor.red)
            Text(title)
                .appStyle(.filmTitle)
                .foregroundStyle(AppColor.ink)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            if let year {
                Text(String(year))
                    .appStyle(.filmYear)
                    .foregroundStyle(AppColor.ink2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
}

/// The primary button pinned under a form. Used as a bottom inset, so it also rides above
/// the keyboard. When `hint` is set the button is dimmed and the hint is shown under it.
struct PinnedActionBar: View {
    let title: String
    var hint: String?
    /// 34pt above the bottom edge; tighter while the keyboard is up.
    var isKeyboardUp = false
    let action: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button(action: action) {
                Text(title)
            }
            .buttonStyle(.primaryPill)
            .disabled(hint != nil)
            .accessibilityHint(hint ?? "")

            if let hint {
                Text(hint)
                    .appStyle(.secondary)
                    .foregroundStyle(AppColor.ink2)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, isKeyboardUp ? 10 : 34)
        .frame(maxWidth: .infinity)
        .background(AppColor.ground)
    }
}

#Preview("Form parts") {
    VStack {
        FormFilmHeader(label: "Now logging", title: "In the Mood for Love", year: 2000)
        Spacer()
        PinnedActionBar(title: "Pick a Design \u{2192}", hint: "Add a one-line review to continue.", action: {})
    }
    .background(AppColor.ground)
}

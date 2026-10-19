import SwiftUI
import UIKit

/// Red chevron and label, 44pt tall. The label names the screen you return to.
struct AppBackButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 2) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                Text(title)
                    .appStyle(.body)
                    .lineLimit(1)
            }
            .fixedSize()
            .foregroundStyle(AppColor.red)
            .padding(.horizontal, 8)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back to \(title)")
    }
}

extension View {
    /// Replaces the system back button with `AppBackButton` and keeps the
    /// swipe-from-the-left-edge gesture working.
    func appBackButton(_ title: String) -> some View {
        modifier(AppBackButtonModifier(title: title))
    }

    /// Turns the swipe-back gesture off for this screen (for example, a ticket
    /// that was just printed and must not be backed out of).
    func swipeBackDisabled() -> some View {
        background(SwipeBackController(isAllowed: false))
    }
}

private struct AppBackButtonModifier: ViewModifier {
    let title: String
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                AppToolbarItem(placement: .topBarLeading) {
                    AppBackButton(title: title) { dismiss() }
                }
            }
            .background(SwipeBackController(isAllowed: true))
    }
}

/// A toolbar item without the round glass backing iOS 26 and later puts behind
/// toolbar items, which would squeeze our own button styling.
struct AppToolbarItem<Content: View>: ToolbarContent {
    let placement: ToolbarItemPlacement
    @ViewBuilder var content: () -> Content

    var body: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: placement, content: content)
                .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: placement, content: content)
        }
    }
}

/// Hiding the system back button also switches off UIKit's edge-swipe pop gesture.
/// This helper takes over that gesture's delegate while its screen is showing, so
/// each screen decides whether swipe-back is allowed.
private struct SwipeBackController: UIViewControllerRepresentable {
    let isAllowed: Bool

    func makeUIViewController(context: Context) -> Controller {
        Controller(isAllowed: isAllowed)
    }

    func updateUIViewController(_ controller: Controller, context: Context) {
        controller.isAllowed = isAllowed
    }

    final class Controller: UIViewController, UIGestureRecognizerDelegate {
        var isAllowed: Bool

        init(isAllowed: Bool) {
            self.isAllowed = isAllowed
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) is not used")
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            navigationController?.interactivePopGestureRecognizer?.delegate = self
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            isAllowed && (navigationController?.viewControllers.count ?? 0) > 1
        }
    }
}

//
//  SnipCommentSampleView.swift
//  visualize
//
//  DEBUG-only sample scene for SNIP-004.
//
//  Renders the visual shape of a snip-as-comment in isolation so XCUIAutomation
//  can assert that the attached image appears, without going through Firebase
//  Auth, Firestore reads, or NavigationStack traversal.
//
//  This view is reachable only when the app is launched with the
//  `-uitest-snip-comment` argument (see VisualizeApp).
//

#if DEBUG
import SwiftUI

struct SnipCommentSampleView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 32, height: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Test User")
                        .font(.subheadline.bold())
                    Text("Snip attached")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // The "snip image" inside the comment. The UI test asserts on this
            // accessibility identifier.
            Image(systemName: "chart.bar.fill")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 280, maxHeight: 200)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityIdentifier("SnipCommentImage")
                .accessibilityLabel("Snip attached to comment")
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
    }
}
#endif

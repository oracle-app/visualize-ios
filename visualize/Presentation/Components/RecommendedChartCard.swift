//
//  RecommendedChartCard.swift
//  visualize
//
//  Created by Nicolás Peralta on 15/04/26.
//

import SwiftUI

/// Selectable card that displays a single chart visualization option.
///
/// The card is stateless regarding title ownership: it fires `onTitleChange`
/// so the caller's ViewModel can validate and persist the new value.
struct RecommendedChartCard: View {

    // MARK: - Input
    let title: String
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil
    var onTitleChange: ((String) -> Void)? = nil

    // MARK: - Edit state
    @State private var isEditAlertPresented = false
    @State private var draft = ""
    private let charLimit = VizReadyViewModel.titleCharLimit

    // MARK: - Body
    var body: some View {
        VStack(spacing: 12) {
            headerRow
            chartPlaceholder
        }
        .padding(16)
        .background(isSelected ? Color.appTeal : Color.appMint)
        .cornerRadius(10)
        .overlay(selectionBorder)
        .shadow(
            color: isSelected ? Color.appOrange.opacity(0.20) : Color.black.opacity(0.15),
            radius: 5,
            x: 0,
            y: isSelected ? 0 : 2
        )
        .shadow(
            color: isSelected ? Color.appOrange.opacity(0.08) : .clear,
            radius: 10,
            x: 0, y: 0
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .padding(.horizontal, 20)
        .frame(height: 390)
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }

    // MARK: - Subviews

    private var headerRow: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(isSelected ? .white : Color.appCardTitle)
                .minimumScaleFactor(0.5)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            editButton
        }
    }

    private var editButton: some View {
        Button {
            draft = title
            isEditAlertPresented = true
        } label: {
            Circle()
                .fill(Color.appButtonBackground)
                .frame(width: 37, height: 37)
                .overlay(
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.appTeal)
                )
                .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .alert("Edit chart title", isPresented: $isEditAlertPresented) {
            TextField("Chart title", text: $draft)
                .onChange(of: draft) { _, new in
                    if new.count > charLimit { draft = String(new.prefix(charLimit)) }
                }
            Button("Cancel", role: .cancel) { }
            Button("Confirm") {
                onTitleChange?(draft)
            }
        } message: {
            Text("Max \(charLimit) characters")
        }
    }

    private var chartPlaceholder: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var selectionBorder: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.white, lineWidth: 2)
            .opacity(isSelected ? 1 : 0)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ScrollView {
        VStack(spacing: 16) {
            RecommendedChartCard(title: "Commerce Activity: Units Sold vs Total Transactions")
            RecommendedChartCard(title: "Units Sold Growth Trend", isSelected: true)
        }
        .padding(.vertical, 24)
    }
    .background(Color.appBackground)
}
#endif

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

    // MARK: - Private palette
    private let orange     = Color(red: 255/255, green: 122/255, blue: 0/255)
    private let teal       = Color(red: 52/255,  green: 121/255, blue: 124/255)
    private let titleColor = Color(red: 26/255,  green: 47/255,  blue: 63/255)
    private let bg         = Color(red: 230/255, green: 237/255, blue: 236/255)
    private let btnBg      = Color(red: 235/255, green: 235/255, blue: 240/255)

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
        .background(isSelected ? teal : bg)
        .cornerRadius(10)
        .overlay(selectionBorder)
        .shadow(
            color: isSelected ? orange.opacity(0.20) : Color.black.opacity(0.12),
            radius: isSelected ? 5 : 6,
            x: 0,
            y: isSelected ? 0 : 3
        )
        .shadow(
            color: isSelected ? orange.opacity(0.08) : .clear,
            radius: 10,
            x: 0, y: 0
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }

    // MARK: - Subviews

    private var headerRow: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(isSelected ? .white : titleColor)
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
                .fill(btnBg)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(teal)
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
            .frame(maxWidth: .infinity)
            .frame(height: 200)
    }

    private var selectionBorder: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.white, lineWidth: 2)
            .opacity(isSelected ? 1 : 0)
    }
}

// MARK: - Preview
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

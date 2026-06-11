//
//  RecommendedChartCard.swift
//  visualize
//
//  Created by Nicolás Peralta on 15/04/26.
//

import SwiftUI
/// Selectable card that displays a single chart visualization option.
/// The card is stateless regarding title ownership: it fires `onTitleChange`
/// so the caller's ViewModel can validate and persist the new value.
struct RecommendedChartCardView: View {
    // MARK: - Input
    let title: String
    /// Parsed chart model to render as a non-interactive preview inside the card.
    /// Falls back to a white placeholder when `nil`.
    var chart: ChartData?
    var isSelected: Bool = false
    var onTap: (() -> Void)?
    var onTitleChange: ((String) -> Void)?
    
    // MARK: - Edit state
    @State private var isEditAlertPresented = false
    @State private var draft = ""
    private let charLimit = VizReadyScreenViewModel.titleCharLimit
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 12) {
            headerRow
            chartPreview
        }
        .padding(16)
        .background(isSelected ? AppColors.Brand.teal : AppColors.Brand.mint)
        .cornerRadius(10)
        .overlay(selectionBorder)
        .shadow(
            color: isSelected ? AppColors.Brand.orange.opacity(0.20) : Color.black.opacity(0.15),
            radius: 5,
            x: 0,
            y: isSelected ? 0 : 2
        )
        .shadow(
            color: isSelected ? AppColors.Brand.orange.opacity(0.08) : .clear,
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
                .foregroundStyle(isSelected ? .white : AppColors.Text.primary)
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
                .fill(.ultraThinMaterial)
                .frame(width: 37, height: 37)
                .overlay(
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColors.UI.card)
                )
                .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .alert("Edit chart title", isPresented: $isEditAlertPresented) {
            TextField(String(localized: "Chart title"), text: $draft)
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
    /// Non-interactive chart preview rendered from the parsed chart model.
    /// `allowsHitTesting(false)` disables zoom, pan, and tooltips in card context.
    /// Falls back to a white rounded rectangle when no chart model is provided.
    private var chartPreview: some View {
        Group {
            if let chart {
                ChartRendererView(chart: chart, isFeedCard: true)
                    .allowsHitTesting(false)
                    .padding(15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .clipShape(.rect(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(.rect(cornerRadius: 10))
    }

    private var selectionBorder: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.appBackground, lineWidth: 2)
            .opacity(isSelected ? 1 : 0)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ScrollView {
        VStack(spacing: 16) {
            RecommendedChartCardView(title: "Commerce Activity: Units Sold vs Total Transactions")
            RecommendedChartCardView(title: "Units Sold Growth Trend", isSelected: true)
        }
        .padding(.vertical, 24)
    }
}
#endif

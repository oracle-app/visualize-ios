//
//  TileChartView.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 03/06/26.
//

import SwiftUI

/// Native SwiftUI view that renders a Tile chart as a group of metric cards.
///
/// - Shows up to 6 tiles in feed-style cards.
/// - Shows up to 9 tiles in larger/full-screen contexts.
/// - Uses a responsive row distribution:
///   1, 2, 2+1, 2+2, 3+2, 3+3, 3+2+2, 3+3+2, 3+3+3.
/// - Numeric strings are abbreviated; non-numeric strings are shown as-is.
struct TileChartView: View {

    // MARK: - Properties

    /// Descriptive labels displayed above the values.
    let labels: [String]

    /// Values to display. Numeric strings are abbreviated; non-numeric strings are shown as-is.
    let values: [String]

    let theme: ChartColorTheme

    /// Feed cards show fewer tiles and scale the content down when there are multiple rows.
    var isFeedCard: Bool = false

    private let maxColumnsPerRow: Int = 3
    private let baseSpacing: CGFloat = 8

    // MARK: - Body

    var body: some View {
        if displayedItems.isEmpty {
            Text(String(localized: "Chart data could not be parsed."))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColors.Text.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            GeometryReader { geometry in
                let rowData = rows
                let availableWidth = geometry.size.width
                let spacing = baseSpacing
                let tileHeight: CGFloat = isFeedCard ? 82 : 96

                VStack(spacing: spacing) {
                    ForEach(rowData.indices, id: \.self) { rowIndex in
                        let row = rowData[rowIndex]
                        let tileWidth = (availableWidth - spacing * CGFloat(row.count - 1)) / CGFloat(row.count)

                        HStack(spacing: spacing) {
                            ForEach(row.indices, id: \.self) { itemIndex in
                                let globalIndex = globalIndexFor(rowIndex: rowIndex, itemIndex: itemIndex)
                                let item = row[itemIndex]

                                tileCard(
                                    label: item.label,
                                    value: item.value,
                                    width: tileWidth,
                                    height: tileHeight,
                                    color: theme.swiftUIColors[globalIndex % theme.swiftUIColors.count]
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }

    // MARK: - Private Properties

    private var tileItems: [TileItem] {
        zip(labels, values).map { TileItem(label: $0.0, value: $0.1) }
    }

    private var displayedItems: [TileItem] {
        Array(tileItems.prefix(isFeedCard ? 6 : 9))
    }

    /// Row distribution
    private var rowCounts: [Int] {
        switch displayedItems.count {
        case 1:
            return [1]
        case 2:
            return [2]
        case 3:
            return [2, 1]
        case 4:
            return [2, 2]
        case 5:
            return [3, 2]
        case 6:
            return [3, 3]
        case 7:
            return [3, 2, 2]
        case 8:
            return [3, 3, 2]
        default:
            return [3, 3, 3]
        }
    }

    private var rows: [[TileItem]] {
        var result: [[TileItem]] = []
        var startIndex = 0

        for rowCount in rowCounts {
            let endIndex = min(startIndex + rowCount, displayedItems.count)
            result.append(Array(displayedItems[startIndex..<endIndex]))
            startIndex = endIndex
        }

        return result
    }

    // MARK: - Private Methods

    private func globalIndexFor(rowIndex: Int, itemIndex: Int) -> Int {
        rowCounts.prefix(rowIndex).reduce(0, +) + itemIndex
    }

    private func tileCard(
        label: String,
        value: String,
        width: CGFloat,
        height: CGFloat,
        color: Color
    ) -> some View {
        VStack(spacing: 7) {
            Text(label)
                .font(isFeedCard ? .caption : .subheadline)
                .foregroundStyle(Color(red: 90 / 255, green: 115 / 255, blue: 114 / 255))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .truncationMode(.tail)
                .minimumScaleFactor(0.85)

            Text(formatValue(value))
                .font(isFeedCard ? .title3 : .title2)
                .bold()
                .foregroundStyle(Color(red: 33 / 255, green: 57 / 255, blue: 75 / 255))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .truncationMode(.tail)
                .minimumScaleFactor(0.85)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .frame(width: width, height: height)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.6), lineWidth: 2)
        )
    }

    // MARK: - Formatting

    private func formatValue(_ value: String) -> String {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let number = Double(trimmedValue) else {
            return trimmedValue
        }

        return formatNumericValue(number)
    }

    private func formatNumericValue(_ value: Double) -> String {
        let absValue = abs(value)
        let sign = value < 0 ? "-" : ""

        switch absValue {
        case 1_000_000_000...:
            return "\(sign)\(formatCompact(absValue / 1_000_000_000))B"
        case 1_000_000...:
            return "\(sign)\(formatCompact(absValue / 1_000_000))M"
        case 1_000...:
            return "\(sign)\(formatCompact(absValue / 1_000))K"
        default:
            return value.truncatingRemainder(dividingBy: 1) == 0
                ? value.formatted(.number.precision(.fractionLength(0)))
                : value.formatted(.number.precision(.fractionLength(2)))
        }
    }

    private func formatCompact(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? value.formatted(.number.precision(.fractionLength(0)))
            : value.formatted(.number.precision(.fractionLength(1)))
    }

    private struct TileItem: Hashable {
        let label: String
        let value: String
    }
}

#Preview("Tile chart") {
    TileChartView(
        labels: ["Passengers", "Survived", "Avg Fare", "Avg Age", "Classes"],
        values: ["891", "342", "32.2", "29.7", "3"],
        theme: .lagoon,
        isFeedCard: true
    )
    .padding()
}

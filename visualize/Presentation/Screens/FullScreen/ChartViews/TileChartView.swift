//
//  TileChartView.swift
//  visualize
//
//  Created by Mariana Carrillo Holguin on 03/06/26.
//

/// Native SwiftUI view that renders a Tile chart as a group of metric cards.
///
/// A Tile is a metric card: a descriptive label on top and a large formatted value below, enclosed in a rounded rectangle border. It does not use SciChart because the chart type is purely textual.
///
/// The value is abbreviated for readability: 800 000 000 -> "$800M", 1 200 000 -> "1.2M", 45 000 -> "45K", 758 -> "758".
///
 
import SwiftUI

struct TileChartView: View {

    // MARK: - Properties

    /// Descriptive label displayed above the value (e.g. "Revenue", "# of Orders").
    let labels: [String]
    /// Numeric values to display (e.g. 800_000_000, 674).
    let values: [Double]
    let theme: ChartColorTheme  // ← agrega esto

    private let columnsPerRow: Int = 3
    private let spacing: CGFloat = 8

    // MARK: - Body

    var body: some View {
        // GeometryReader is used here instead of containerRelativeFrame() because
        // we need both available width (for tileWidth) and available height (for
        // maxTileHeight to prevent landscape clipping). containerRelativeFrame()
        // only provides one dimension at a time.
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let availableHeight = geometry.size.height
            let tileWidth = (availableWidth - spacing * CGFloat(columnsPerRow - 1)) / CGFloat(columnsPerRow)
            let maxTileHeight = (availableHeight - spacing * CGFloat(rows.count - 1)) / CGFloat(rows.count)
            let tileHeight = min(tileWidth * 0.75, maxTileHeight)

            VStack {
                Spacer()
                VStack(spacing: spacing) {
                    ForEach(rows.indices, id: \.self) { rowIndex in
                        HStack(spacing: spacing) {
                            ForEach(rows[rowIndex].indices, id: \.self) { itemIndex in
                                let item = rows[rowIndex][itemIndex]
                                tileCard(
                                    label: item.label,
                                    value: item.value,
                                    width: tileWidth,
                                    height: tileHeight,
                                    color: theme.swiftUIColors[itemIndex % theme.swiftUIColors.count]
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Private Properties

    private var tileItems: [TileItem] {
        zip(labels, values).map { TileItem(label: $0.0, value: $0.1) }
    }

    private var rows: [[TileItem]] {
        stride(from: 0, to: tileItems.count, by: columnsPerRow).map { startIndex in
            let endIndex = min(startIndex + columnsPerRow, tileItems.count)
            return Array(tileItems[startIndex..<endIndex])
        }
    }

    // MARK: - Private Methods

    private func tileCard(label: String, value: Double, width: CGFloat, height: CGFloat, color: Color) -> some View {
        VStack(spacing: 7) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color(red: 90 / 255, green: 115 / 255, blue: 114 / 255))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .truncationMode(.tail)
                .minimumScaleFactor(0.85)

            Text(formatValue(value))
                .font(.title2)
                .bold()
                .foregroundStyle(Color(red: 33 / 255, green: 57 / 255, blue: 75 / 255))
                .multilineTextAlignment(.center)
                .lineLimit(1)
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
                .stroke(color.opacity(0.6), lineWidth: 2)  // ← usa el color del tema
        )
    }

    // MARK: - Formatting
    /// Abbreviates the value into a human-readable string.
    /// - 1 200 000 000 -> "1.2B"
    /// - 800 000 000 -> "800M"
    /// - 1 200 000 -> "1.2M"
    /// - 45 000 -> "45K"
    /// - 758 -> "758"
    /// - 0.75 -> "0.75"
    private func formatValue(_ value: Double) -> String {
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
}

private struct TileItem: Hashable {
    let label: String
    let value: Double
}

#Preview("Tile chart") {
    TileChartView(
        labels: ["Passengers", "Survived", "Avg Fare", "Avg Age", "Classes"],
        values: [891, 342, 32.2, 29.7, 3],
        theme: .lagoon
    )
    .padding()
}

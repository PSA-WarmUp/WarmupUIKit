//
//  DSMuscleBar.swift
//  WarmupUIKit
//
//  Horizontal muscle-group summary bar for the workout builder.
//

import SwiftUI

public struct DSMuscleBar: View {
    let setsByCategory: [(category: String, sets: Int)]
    let totalSets: Int

    private static let canonical = ["Chest", "Back", "Delts", "Arms", "Legs", "Core"]

    public init(setsByCategory: [(category: String, sets: Int)], totalSets: Int) {
        self.setsByCategory = setsByCategory
        self.totalSets = totalSets
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Self.canonical, id: \.self) { group in
                let sets = setsByCategory.first(where: { $0.category == group })?.sets ?? 0
                let active = sets > 0

                VStack(spacing: DS.Space.v4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(active ? DS.Color.primary : DS.Color.cardHi)
                        .frame(height: 4)

                    Text(group)
                        .font(DS.Typo.caption)
                        .foregroundStyle(active ? DS.Color.text : DS.Color.textTer)
                }
                .frame(maxWidth: .infinity)
            }

            // Total sets badge
            VStack(spacing: DS.Space.v4) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.clear)
                    .frame(height: 4)

                Text("\(totalSets)")
                    .font(DS.Typo.captionMedium)
                    .foregroundStyle(DS.Color.textSec)
            }
            .frame(width: 36)
        }
        .padding(.horizontal, DS.Space.cardPad)
        .padding(.vertical, DS.Space.v8)
        .background(DS.Color.card)
        .clipShape(RoundedRectangle(cornerRadius: DS.Space.innerRadius))
    }
}

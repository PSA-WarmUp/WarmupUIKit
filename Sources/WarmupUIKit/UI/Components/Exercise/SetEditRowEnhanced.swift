//
//  SetEditRowEnhanced.swift
//  WarmupUIKit
//
//  Enhanced set editing row with rep ranges and RPE/RIR support
//

import SwiftUI

// MARK: - Set Edit Row Enhanced

/// An enhanced set editing row that supports rep ranges and RPE/RIR effort tracking
public struct SetEditRowEnhanced: View {
    @Binding public var set: ExerciseSet
    public let setNumber: Int

    /// The default effort type from workout settings
    public var workoutEffortType: EffortType = .none

    /// Callback when set is deleted
    public var onDelete: (() -> Void)?

    /// Whether to show delete button
    public var showDeleteButton: Bool = true

    /// Callback when set number is tapped (for cycling sets)
    public var onSetNumberTap: (() -> Void)?

    public init(
        set: Binding<ExerciseSet>,
        setNumber: Int,
        workoutEffortType: EffortType = .none,
        showDeleteButton: Bool = true,
        onDelete: (() -> Void)? = nil,
        onSetNumberTap: (() -> Void)? = nil
    ) {
        self._set = set
        self.setNumber = setNumber
        self.workoutEffortType = workoutEffortType
        self.showDeleteButton = showDeleteButton
        self.onDelete = onDelete
        self.onSetNumberTap = onSetNumberTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Row 1: set number + rep range (+ delete)
            HStack(spacing: 10) {
                setNumberButton
                repRangeInputs
                Spacer(minLength: 0)
                if showDeleteButton {
                    Button(action: { onDelete?() }) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.7))
                    }
                }
            }
            // Row 2: weight + target RPE — BOTH always visible (no hidden menu, no clipping)
            HStack(spacing: 14) {
                weightField
                rpeField
                Spacer(minLength: 0)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(DynamicTheme.Colors.cardBackground)
        .cornerRadius(DynamicTheme.Radius.small)
    }

    // MARK: - Set Number Button

    private var setNumberButton: some View {
        Button(action: { onSetNumberTap?() }) {
            Text("Set \(setNumber)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(DynamicTheme.Colors.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(DynamicTheme.Colors.background)
                .cornerRadius(DynamicTheme.Radius.small)
        }
    }

    // MARK: - Rep Range Inputs

    /// Min / max rep boxes.
    ///
    /// The max box used to fall back to `set.reps` when `maxReps` was nil, so a set defaulted
    /// to 12 reps rendered a solid "12" that looked entered. The trainer saw "8 - 12" while
    /// the model held `maxReps: nil`, and the workout — correctly — showed "8". Now an unset
    /// max renders as an actual placeholder, so the boxes and the workout always agree.
    private var repRangeInputs: some View {
        HStack(spacing: 4) {
            // Min — falls back to the single rep count, which genuinely is the low value.
            TextField("reps", text: Binding(
                get: { (set.minReps ?? set.reps).map(String.init) ?? "" },
                set: { set.minReps = Int($0) }
            ))
            .textFieldStyle(.plain)
            .keyboardType(.numberPad)
            .frame(width: 35)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(DynamicTheme.Colors.background)
            .cornerRadius(DynamicTheme.Radius.small)

            Text("-")
                .font(.caption)
                .foregroundColor(DynamicTheme.Colors.textSecondary)

            // Max — only ever its own value. Empty means "no range", and that is the truth.
            TextField("max", text: Binding(
                get: { set.maxReps.map(String.init) ?? "" },
                set: { set.maxReps = Int($0) }
            ))
            .textFieldStyle(.plain)
            .keyboardType(.numberPad)
            .frame(width: 35)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(DynamicTheme.Colors.background)
            .cornerRadius(DynamicTheme.Radius.small)

            Text("reps")
                .font(.caption)
                .foregroundColor(DynamicTheme.Colors.textSecondary)
        }
    }

    // MARK: - Weight (always visible)

    private var weightField: some View {
        HStack(spacing: 6) {
            Text("Weight")
                .font(.caption)
                .foregroundColor(DynamicTheme.Colors.textSecondary)
            TextField("—", text: Binding(
                get: { set.weight ?? "" },
                set: { set.weight = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(.plain)
            .keyboardType(.decimalPad)
            .frame(width: 68)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(DynamicTheme.Colors.background)
            .cornerRadius(DynamicTheme.Radius.small)
        }
    }

    // MARK: - Target RPE (always visible, optional, tap to pick)

    private var rpeField: some View {
        HStack(spacing: 6) {
            Text("RPE")
                .font(.caption)
                .foregroundColor(DynamicTheme.Colors.textSecondary)
            Menu {
                Button("None") { set.targetRpe = nil }
                // Target RPE in 0.5 steps, 1.0–10.0 (contract §9/D3)
                ForEach(Array(stride(from: 1.0, through: 10.0, by: 0.5)), id: \.self) { value in
                    Button(ExerciseSet.formatRpe(value)) {
                        set.targetRpe = value
                        if (set.effortType ?? "").isEmpty { set.effortType = "RPE" }
                    }
                }
            } label: {
                Text(set.targetRpe.map { ExerciseSet.formatRpe($0) } ?? "—")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DynamicTheme.Colors.primary)
                    .frame(minWidth: 44)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(DynamicTheme.Colors.background)
                    .cornerRadius(DynamicTheme.Radius.small)
            }
        }
    }
}

// MARK: - Compact Set Display

/// A compact read-only display of a set for summary views
public struct SetDisplayCompact: View {
    public let set: ExerciseSet
    public let setNumber: Int

    public init(set: ExerciseSet, setNumber: Int) {
        self.set = set
        self.setNumber = setNumber
    }

    public var body: some View {
        HStack(spacing: 8) {
            Text("Set \(setNumber)")
                .font(.caption)
                .foregroundColor(DynamicTheme.Colors.textSecondary)

            Text(set.repRangeDisplay)
                .font(.subheadline)
                .fontWeight(.medium)

            if !set.effortDisplay.isEmpty {
                Text("@")
                    .font(.caption)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)

                Text(set.effortDisplay)
                    .font(.subheadline)
                    .foregroundColor(effortColor)
            }
        }
    }

    private var effortColor: Color {
        switch set.effortTypeEnum {
        case .rpe:
            if let rpe = set.rpeValue {
                if rpe >= 9 { return .red }
                if rpe >= 7 { return .orange }
            }
            return DynamicTheme.Colors.text
        case .rir:
            if let rir = set.rirValue {
                if rir <= 1 { return .red }
                if rir <= 2 { return .orange }
            }
            return DynamicTheme.Colors.text
        case .none:
            return DynamicTheme.Colors.text
        }
    }
}

// MARK: - Set Count Cycler

/// A tappable set count that cycles through common values
public struct SetCountCycler: View {
    @Binding public var setCount: Int
    public var cycleValues: [Int] = [2, 3, 4, 5]

    public init(setCount: Binding<Int>, cycleValues: [Int] = [2, 3, 4, 5]) {
        self._setCount = setCount
        self.cycleValues = cycleValues
    }

    public var body: some View {
        Button(action: cycle) {
            HStack(spacing: 4) {
                Text("\(setCount)")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("sets")
                    .font(.caption)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(DynamicTheme.Colors.cardBackground)
            .cornerRadius(DynamicTheme.Radius.small)
        }
        .foregroundColor(DynamicTheme.Colors.text)
    }

    private func cycle() {
        if let currentIndex = cycleValues.firstIndex(of: setCount) {
            let nextIndex = (currentIndex + 1) % cycleValues.count
            setCount = cycleValues[nextIndex]
        } else {
            // If current value not in cycle, start at first value
            setCount = cycleValues.first ?? 3
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SetEditRowEnhanced_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            SetEditRowEnhanced(
                set: .constant(ExerciseSet(
                    reps: 10,
                    minReps: 8,
                    maxReps: 12,
                    weight: 135,
                    effortType: "RPE"
                )),
                setNumber: 1
            )

            SetEditRowEnhanced(
                set: .constant(ExerciseSet(
                    minReps: 6,
                    maxReps: 8,
                    rir: 2,
                    effortType: "RIR"
                )),
                setNumber: 2
            )

            SetDisplayCompact(
                set: ExerciseSet(minReps: 8, maxReps: 12, targetRpe: 8, effortType: "RPE"),
                setNumber: 1
            )

            SetCountCycler(setCount: .constant(3))
        }
        .padding()
        .background(DynamicTheme.Colors.background)
    }
}
#endif

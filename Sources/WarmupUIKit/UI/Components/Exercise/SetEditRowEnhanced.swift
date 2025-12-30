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
        HStack(spacing: 12) {
            // Set number (tappable to cycle)
            setNumberButton

            // Rep range inputs
            repRangeInputs

            // Divider
            Text("@")
                .font(.caption)
                .foregroundColor(DynamicTheme.Colors.textSecondary)

            // Effort input (weight, RPE, or RIR)
            effortInput

            Spacer()

            // Delete button
            if showDeleteButton {
                Button(action: { onDelete?() }) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.7))
                }
            }
        }
        .padding(.vertical, 8)
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

    private var repRangeInputs: some View {
        HStack(spacing: 4) {
            // Min reps
            TextField("", value: Binding(
                get: { set.minReps ?? set.reps ?? 0 },
                set: { set.minReps = $0 > 0 ? $0 : nil }
            ), format: .number)
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

            // Max reps
            TextField("", value: Binding(
                get: { set.maxReps ?? set.reps ?? 0 },
                set: { set.maxReps = $0 > 0 ? $0 : nil }
            ), format: .number)
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

    // MARK: - Effort Input

    private var effortInput: some View {
        let currentEffortType = set.effortTypeEnum

        return HStack(spacing: 8) {
            // Effort type toggle
            Menu {
                ForEach(EffortType.allCases, id: \.self) { type in
                    Button(action: {
                        set.effortType = type.rawValue
                    }) {
                        HStack {
                            Text(type.displayName)
                            if currentEffortType == type {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Text(currentEffortType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DynamicTheme.Colors.primary)
            }

            // Value input based on effort type
            switch currentEffortType {
            case .none:
                weightInput
            case .rpe:
                rpeInput
            case .rir:
                rirInput
            }
        }
    }

    // MARK: - Weight Input

    private var weightInput: some View {
        HStack(spacing: 4) {
            TextField("", text: Binding(
                get: { set.weight ?? "" },
                set: { set.weight = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(.plain)
            .keyboardType(.decimalPad)
            .frame(width: 50)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(DynamicTheme.Colors.background)
            .cornerRadius(DynamicTheme.Radius.small)

            Text("lbs")
                .font(.caption)
                .foregroundColor(DynamicTheme.Colors.textSecondary)
        }
    }

    // MARK: - RPE Input

    private var rpeInput: some View {
        HStack(spacing: 4) {
            Text("RPE")
                .font(.caption)
                .foregroundColor(DynamicTheme.Colors.textSecondary)

            Picker("", selection: Binding(
                get: { set.rpeValue ?? 8 },
                set: { set.rpe = "\($0)" }
            )) {
                ForEach(1...10, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 50)
        }
    }

    // MARK: - RIR Input

    private var rirInput: some View {
        HStack(spacing: 4) {
            Picker("", selection: Binding(
                get: { set.rirValue ?? 2 },
                set: { set.rir = "\($0)" }
            )) {
                ForEach(0...5, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 40)

            Text("RIR")
                .font(.caption)
                .foregroundColor(DynamicTheme.Colors.textSecondary)
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
                set: ExerciseSet(minReps: 8, maxReps: 12, rpe: 8, effortType: "RPE"),
                setNumber: 1
            )

            SetCountCycler(setCount: .constant(3))
        }
        .padding()
        .background(DynamicTheme.Colors.background)
    }
}
#endif

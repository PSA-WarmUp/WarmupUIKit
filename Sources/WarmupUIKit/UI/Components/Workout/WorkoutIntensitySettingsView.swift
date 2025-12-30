//
//  WorkoutIntensitySettingsView.swift
//  WarmupUIKit
//
//  Workout-level intensity/effort settings component
//

import SwiftUI

// MARK: - Workout Intensity Settings View

/// A settings section for configuring workout-level intensity defaults
public struct WorkoutIntensitySettingsView: View {
    @Binding public var effortType: EffortType
    @Binding public var effortValue: Int

    public var showHeader: Bool = true
    public var isCompact: Bool = false

    public init(
        effortType: Binding<EffortType>,
        effortValue: Binding<Int>,
        showHeader: Bool = true,
        isCompact: Bool = false
    ) {
        self._effortType = effortType
        self._effortValue = effortValue
        self.showHeader = showHeader
        self.isCompact = isCompact
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 8 : 12) {
            if showHeader {
                Text("Workout Intensity")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
            }

            // Effort type picker
            VStack(alignment: .leading, spacing: 4) {
                Text("Effort Tracking")
                    .font(.caption)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)

                Picker("Effort Type", selection: $effortType) {
                    ForEach(EffortType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Effort value (only shown when RPE or RIR is selected)
            if effortType != .none {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Default \(effortType.displayName)")
                            .font(.caption)
                            .foregroundColor(DynamicTheme.Colors.textSecondary)

                        Spacer()

                        Text(effortValueDisplay)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(effortValueColor)
                    }

                    // Slider or stepper based on effort type
                    if effortType == .rpe {
                        Slider(value: Binding(
                            get: { Double(effortValue) },
                            set: { effortValue = Int($0) }
                        ), in: 1...10, step: 1)
                        .tint(effortValueColor)

                        // RPE scale labels
                        HStack {
                            Text("1 (Easy)")
                                .font(.caption2)
                                .foregroundColor(DynamicTheme.Colors.textSecondary)
                            Spacer()
                            Text("10 (Max)")
                                .font(.caption2)
                                .foregroundColor(DynamicTheme.Colors.textSecondary)
                        }
                    } else if effortType == .rir {
                        Slider(value: Binding(
                            get: { Double(effortValue) },
                            set: { effortValue = Int($0) }
                        ), in: 0...5, step: 1)
                        .tint(effortValueColor)

                        // RIR scale labels
                        HStack {
                            Text("0 (Failure)")
                                .font(.caption2)
                                .foregroundColor(DynamicTheme.Colors.textSecondary)
                            Spacer()
                            Text("5 (Easy)")
                                .font(.caption2)
                                .foregroundColor(DynamicTheme.Colors.textSecondary)
                        }
                    }
                }
                .padding(.top, 4)
            }

            // Info text
            Text(infoText)
                .font(.caption)
                .foregroundColor(DynamicTheme.Colors.textSecondary)
                .padding(.top, 4)
        }
        .padding(isCompact ? 12 : 16)
        .background(DynamicTheme.Colors.cardBackground)
        .cornerRadius(DynamicTheme.Radius.medium)
    }

    private var effortValueDisplay: String {
        switch effortType {
        case .rpe:
            return "RPE \(effortValue)"
        case .rir:
            return "\(effortValue) RIR"
        case .none:
            return ""
        }
    }

    private var effortValueColor: Color {
        switch effortType {
        case .rpe:
            if effortValue >= 9 { return .red }
            if effortValue >= 7 { return .orange }
            if effortValue >= 5 { return .yellow }
            return .green
        case .rir:
            if effortValue <= 1 { return .red }
            if effortValue <= 2 { return .orange }
            if effortValue <= 3 { return .yellow }
            return .green
        case .none:
            return DynamicTheme.Colors.primary
        }
    }

    private var infoText: String {
        switch effortType {
        case .none:
            return "Exercises will use weight targets (lbs/kg)"
        case .rpe:
            return "All new exercises will default to RPE \(effortValue)"
        case .rir:
            return "All new exercises will default to \(effortValue) reps in reserve"
        }
    }
}

// MARK: - Compact Effort Type Picker

/// A compact inline picker for effort type selection
public struct EffortTypePicker: View {
    @Binding public var effortType: EffortType

    public init(effortType: Binding<EffortType>) {
        self._effortType = effortType
    }

    public var body: some View {
        Menu {
            ForEach(EffortType.allCases, id: \.self) { type in
                Button(action: { effortType = type }) {
                    HStack {
                        Text(type.displayName)
                        if effortType == type {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(effortType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .foregroundColor(DynamicTheme.Colors.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(DynamicTheme.Colors.primary.opacity(0.1))
            .cornerRadius(DynamicTheme.Radius.small)
        }
    }
}

// MARK: - Effort Value Stepper

/// A compact stepper for RPE/RIR values
public struct EffortValueStepper: View {
    @Binding public var value: Int
    public let effortType: EffortType

    public init(value: Binding<Int>, effortType: EffortType) {
        self._value = value
        self.effortType = effortType
    }

    private var range: ClosedRange<Int> {
        switch effortType {
        case .rpe: return 1...10
        case .rir: return 0...5
        case .none: return 0...0
        }
    }

    public var body: some View {
        HStack(spacing: 8) {
            Button(action: decrement) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(value > range.lowerBound ? DynamicTheme.Colors.primary : DynamicTheme.Colors.textSecondary)
            }
            .disabled(value <= range.lowerBound)

            Text("\(value)")
                .font(.headline)
                .fontWeight(.bold)
                .frame(minWidth: 30)

            Button(action: increment) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(value < range.upperBound ? DynamicTheme.Colors.primary : DynamicTheme.Colors.textSecondary)
            }
            .disabled(value >= range.upperBound)
        }
    }

    private func increment() {
        if value < range.upperBound {
            value += 1
        }
    }

    private func decrement() {
        if value > range.lowerBound {
            value -= 1
        }
    }
}

// MARK: - Preview

#if DEBUG
struct WorkoutIntensitySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            WorkoutIntensitySettingsView(
                effortType: .constant(.rpe),
                effortValue: .constant(8)
            )

            WorkoutIntensitySettingsView(
                effortType: .constant(.rir),
                effortValue: .constant(2),
                isCompact: true
            )

            HStack {
                EffortTypePicker(effortType: .constant(.rpe))
                EffortValueStepper(value: .constant(8), effortType: .rpe)
            }
        }
        .padding()
        .background(DynamicTheme.Colors.background)
    }
}
#endif

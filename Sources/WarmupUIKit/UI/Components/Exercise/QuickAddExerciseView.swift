//
//  QuickAddExerciseView.swift
//  WarmupUIKit
//
//  Inline quick-add exercise component for workout creation
//

import SwiftUI

// MARK: - Quick Add Exercise View

/// A compact inline view for quickly adding exercises without leaving the workout flow
public struct QuickAddExerciseView: View {
    @State private var exerciseName: String = ""
    @State private var isCreating: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    /// Callback when exercise is successfully created
    public let onExerciseCreated: (Exercise) -> Void

    /// Optional callback for cancellation
    public var onCancel: (() -> Void)?

    /// Placeholder text
    public var placeholder: String = "Quick add exercise..."

    /// Whether to show the cancel button
    public var showCancelButton: Bool = false

    public init(
        onExerciseCreated: @escaping (Exercise) -> Void,
        onCancel: (() -> Void)? = nil,
        placeholder: String = "Quick add exercise...",
        showCancelButton: Bool = false
    ) {
        self.onExerciseCreated = onExerciseCreated
        self.onCancel = onCancel
        self.placeholder = placeholder
        self.showCancelButton = showCancelButton
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Text field
            HStack {
                Image(systemName: "plus.circle")
                    .foregroundColor(DynamicTheme.Colors.textSecondary)

                TextField(placeholder, text: $exerciseName)
                    .textFieldStyle(.plain)
                    .submitLabel(.done)
                    .onSubmit {
                        createExercise()
                    }

                if !exerciseName.isEmpty {
                    Button(action: { exerciseName = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DynamicTheme.Colors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(DynamicTheme.Colors.cardBackground)
            .cornerRadius(DynamicTheme.Radius.medium)

            // Add button
            Button(action: createExercise) {
                if isCreating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 20, height: 20)
                } else {
                    Text("Add")
                        .fontWeight(.semibold)
                }
            }
            .disabled(exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating
                    ? DynamicTheme.Colors.textSecondary.opacity(0.3)
                    : DynamicTheme.Colors.primary
            )
            .foregroundColor(.white)
            .cornerRadius(DynamicTheme.Radius.medium)

            // Cancel button (optional)
            if showCancelButton {
                Button(action: { onCancel?() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(DynamicTheme.Colors.textSecondary)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func createExercise() {
        let name = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        isCreating = true

        Task {
            do {
                let request = QuickAddExerciseRequest(name: name)
                let exercise = try await ExercisePreferencesService.shared.quickAddExercise(request)

                await MainActor.run {
                    isCreating = false
                    exerciseName = ""
                    onExerciseCreated(exercise)
                }
            } catch {
                await MainActor.run {
                    isCreating = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Quick Add Row (for use in lists)

/// A list row version of quick add for inline use in exercise lists
public struct QuickAddExerciseRow: View {
    @State private var isExpanded: Bool = false

    public let onExerciseCreated: (Exercise) -> Void

    public init(onExerciseCreated: @escaping (Exercise) -> Void) {
        self.onExerciseCreated = onExerciseCreated
    }

    public var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                QuickAddExerciseView(
                    onExerciseCreated: { exercise in
                        isExpanded = false
                        onExerciseCreated(exercise)
                    },
                    onCancel: { isExpanded = false },
                    showCancelButton: true
                )
                .padding()
                .background(DynamicTheme.Colors.cardBackground.opacity(0.5))
            } else {
                Button(action: { isExpanded = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(DynamicTheme.Colors.primary)

                        Text("Quick add exercise")
                            .foregroundColor(DynamicTheme.Colors.primary)

                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct QuickAddExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            QuickAddExerciseView(onExerciseCreated: { _ in })
                .padding()

            QuickAddExerciseRow(onExerciseCreated: { _ in })
        }
        .background(DynamicTheme.Colors.background)
    }
}
#endif

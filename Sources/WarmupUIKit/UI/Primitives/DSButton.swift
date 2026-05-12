//
//  DSButton.swift
//  WarmupUIKit
//
//  Single source of truth for buttons across the trainer and athlete apps.
//

import SwiftUI

// MARK: - Variant + size

public enum DSButtonVariant {
    case primary
    case secondary
    case tertiary
    case destructive
    case ghost
}

public enum DSButtonSize {
    case sm
    case md
    case lg

    var verticalPadding: CGFloat {
        switch self {
        case .sm: return 8
        case .md: return 12
        case .lg: return 16
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .sm: return 12
        case .md: return 16
        case .lg: return 20
        }
    }

    var minHeight: CGFloat {
        switch self {
        case .sm: return 36
        case .md: return 44
        case .lg: return 52
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .sm: return 10
        case .md: return 12
        case .lg: return 14
        }
    }
}

// MARK: - DSButton convenience view

/// `DSButton("Save") { … }` — the standard way to create a button.
public struct DSButton: View {
    let title: String
    let icon: String?
    let variant: DSButtonVariant
    let size: DSButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    let fullWidth: Bool
    let haptic: Bool
    let action: () -> Void

    public init(
        _ title: String,
        icon: String? = nil,
        variant: DSButtonVariant = .primary,
        size: DSButtonSize = .md,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        fullWidth: Bool = true,
        haptic: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.fullWidth = fullWidth
        self.haptic = haptic
        self.action = action
    }

    public var body: some View {
        Button(role: variant == .destructive ? .destructive : nil) {
            if haptic && !isLoading && !isDisabled {
                switch variant {
                case .primary, .destructive: DS.Haptic.light()
                case .secondary, .tertiary, .ghost: DS.Haptic.selection()
                }
            }
            action()
        } label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                        .tint(foregroundColor(for: variant))
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: iconSize, weight: .semibold))
                    }
                    Text(title)
                        .font(.system(.headline, design: .default).weight(.semibold))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
        }
        .buttonStyle(DSButtonStyle(
            variant: variant,
            size: size,
            isDisabled: isDisabled || isLoading
        ))
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isLoading ? .isStaticText : [])
    }

    private var iconSize: CGFloat {
        switch size { case .sm: return 13; case .md: return 15; case .lg: return 17 }
    }

    private func foregroundColor(for variant: DSButtonVariant) -> Color {
        switch variant {
        case .primary, .destructive: return DS.Color.onPrimary
        case .secondary, .tertiary, .ghost: return DS.Tone.accent
        }
    }
}

// MARK: - DSButtonStyle (low-level)

/// Lower-level style for when you need a `Button { … } label: { customView }`.
public struct DSButtonStyle: ButtonStyle {
    let variant: DSButtonVariant
    let size: DSButtonSize
    let isDisabled: Bool

    public init(
        variant: DSButtonVariant = .primary,
        size: DSButtonSize = .md,
        isDisabled: Bool = false
    ) {
        self.variant = variant
        self.size = size
        self.isDisabled = isDisabled
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .frame(minHeight: size.minHeight)
            .foregroundColor(foreground(pressed: configuration.isPressed))
            .background(background(pressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
            .overlay(
                Group {
                    if (variant == .tertiary || variant == .ghost) && !isDisabled {
                        RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                            .stroke(DS.Color.hairline, lineWidth: DS.Space.hairlineWidth)
                    }
                }
            )
            .scaleEffect(configuration.isPressed && !isDisabled ? 0.97 : 1.0)
            .animation(DS.Motion.tap, value: configuration.isPressed)
            .contentShape(Rectangle())
    }

    private func foreground(pressed: Bool) -> Color {
        if isDisabled {
            return DS.Color.onDisabled
        }
        switch variant {
        case .primary, .destructive: return DS.Color.onPrimary
        case .secondary, .tertiary, .ghost: return DS.Tone.accent
        }
    }

    @ViewBuilder
    private func background(pressed: Bool) -> some View {
        if isDisabled {
            DS.Color.disabled
        } else {
            switch variant {
            case .primary:
                DS.Tone.accent
                    .overlay(pressed ? Color.black.opacity(0.06) : Color.clear)
            case .destructive:
                DS.Color.error
                    .overlay(pressed ? Color.black.opacity(0.06) : Color.clear)
            case .secondary:
                DS.Color.primarySoft
                    .overlay(pressed ? DS.Tone.accent.opacity(0.06) : Color.clear)
            case .tertiary:
                Color.clear
                    .overlay(pressed ? DS.Color.cardHi : Color.clear)
            case .ghost:
                Color.clear
                    .overlay(pressed ? DS.Color.cardHi.opacity(0.6) : Color.clear)
            }
        }
    }
}

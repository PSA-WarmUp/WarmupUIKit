//
//  CalendarComponents.swift
//  WarmupUIKit
//
//  Shareable calendar UI components for trainer and client apps
//

import SwiftUI

// MARK: - Calendar Event Protocol

/// Protocol for calendar events that can be displayed on the hourly calendar
public protocol CalendarEventDisplayable: Identifiable {
    var id: String { get }
    var title: String { get }
    var subtitle: String { get }
    var scheduledDate: Date? { get }
    var durationMinutes: Int { get }
    var eventType: CalendarEventType { get }
    var status: CalendarEventStatus { get }
}

/// Type of calendar event
public enum CalendarEventType {
    case workout
    case consultation
    case custom(icon: String, color: Color)

    public var icon: String {
        switch self {
        case .workout: return "dumbbell.fill"
        case .consultation: return "calendar.badge.clock"
        case .custom(let icon, _): return icon
        }
    }

    public var color: Color {
        switch self {
        case .workout: return DynamicTheme.Colors.primary
        case .consultation: return Color.teal
        case .custom(_, let color): return color
        }
    }
}

/// Status of a calendar event
public enum CalendarEventStatus {
    case scheduled
    case inProgress
    case completed
    case cancelled
    case canStart

    public var color: Color {
        switch self {
        case .scheduled: return DynamicTheme.Colors.secondary
        case .inProgress: return DynamicTheme.Colors.primary
        case .completed: return DynamicTheme.Colors.success
        case .cancelled: return DynamicTheme.Colors.error
        case .canStart: return DynamicTheme.Colors.primary.opacity(0.9)
        }
    }

    public var displayText: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .canStart: return "Ready"
        }
    }
}

// MARK: - Hour Slot View

/// A single hour slot in the hourly calendar view
public struct HourSlotView: View {
    public let hour: Int
    public let date: Date
    public let height: CGFloat
    public let onTap: (Date) -> Void

    public init(hour: Int, date: Date, height: CGFloat, onTap: @escaping (Date) -> Void) {
        self.hour = hour
        self.date = date
        self.height = height
        self.onTap = onTap
    }

    private var hourString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = 0
        if let hourDate = Calendar.current.date(from: components) {
            return formatter.string(from: hourDate)
        }
        return "\(hour)"
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Time label
            Text(hourString)
                .font(DynamicTheme.Typography.caption)
                .foregroundColor(DynamicTheme.Colors.textTertiary)
                .frame(width: 50, alignment: .trailing)
                .padding(.trailing, DynamicTheme.Spacing.sm)

            // Divider line
            VStack(spacing: 0) {
                Rectangle()
                    .fill(DynamicTheme.Colors.divider.opacity(0.5))
                    .frame(height: 1)

                Spacer()
            }
        }
        .frame(height: height)
        .contentShape(Rectangle())
        .onTapGesture {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            components.hour = hour
            components.minute = 0
            if let tappedDate = Calendar.current.date(from: components) {
                onTap(tappedDate)
            }
        }
    }
}

// MARK: - Calendar Day Cell

/// A day cell for the week strip calendar view
public struct CalendarDayCell: View {
    public let date: Date
    public let isSelected: Bool
    public let isToday: Bool
    public let hasItems: Bool
    public let itemCount: Int
    public let weekdayName: String
    public let dayNumber: String
    public let onTap: () -> Void

    @State private var isPressed = false

    public init(
        date: Date,
        isSelected: Bool,
        isToday: Bool,
        hasItems: Bool,
        weekdayName: String,
        dayNumber: String,
        itemCount: Int = 0,
        onTap: @escaping () -> Void
    ) {
        self.date = date
        self.isSelected = isSelected
        self.isToday = isToday
        self.hasItems = hasItems
        self.itemCount = itemCount
        self.weekdayName = weekdayName
        self.dayNumber = dayNumber
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: {
            withAnimation(DynamicTheme.Animations.spring) {
                onTap()
            }
        }) {
            VStack(spacing: DynamicTheme.Spacing.xs) {
                // Weekday name
                Text(weekdayName)
                    .font(DynamicTheme.Typography.caption)
                    .foregroundColor(isSelected ? .white : DynamicTheme.Colors.textSecondary)

                // Day number
                Text(dayNumber)
                    .font(DynamicTheme.Typography.bodyMedium)
                    .fontWeight(isToday ? .bold : .medium)
                    .foregroundColor(isSelected ? .white : DynamicTheme.Colors.text)

                // Multi-item indicator dots
                itemIndicator
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DynamicTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DynamicTheme.Radius.large, style: .continuous)
                    .fill(backgroundColor)
                    .shadow(
                        color: isSelected ? DynamicTheme.Colors.primary.opacity(0.3) : .clear,
                        radius: isSelected ? 8 : 0,
                        y: isSelected ? 2 : 0
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: DynamicTheme.Radius.large, style: .continuous)
                    .strokeBorder(isToday && !isSelected ? DynamicTheme.Colors.primary : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(DynamicTheme.Animations.spring, value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(DynamicTheme.Animations.quick) { isPressed = true }
        } onRelease: {
            withAnimation(DynamicTheme.Animations.quick) { isPressed = false }
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return DynamicTheme.Colors.primary
        } else {
            return DynamicTheme.Colors.cardBackground
        }
    }

    @ViewBuilder
    private var itemIndicator: some View {
        if hasItems {
            HStack(spacing: 3) {
                // Show up to 3 dots based on item count
                ForEach(0..<min(itemCount, 3), id: \.self) { index in
                    Circle()
                        .fill(isSelected ? .white : dotColor(for: index))
                        .frame(width: 5, height: 5)
                }
            }
            .frame(height: 6)
        } else {
            Color.clear.frame(height: 6)
        }
    }

    private func dotColor(for index: Int) -> Color {
        // First dot is primary, subsequent dots fade slightly
        switch index {
        case 0: return DynamicTheme.Colors.primary
        case 1: return DynamicTheme.Colors.secondary
        default: return DynamicTheme.Colors.primary.opacity(0.5)
        }
    }
}

// MARK: - Calendar Status Badge

/// A badge for displaying event status
public struct CalendarStatusBadge: View {
    public let status: String

    public init(status: String) {
        self.status = status
    }

    public var body: some View {
        Text(displayText)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(textColor)
            .padding(.horizontal, DynamicTheme.Spacing.sm)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: DynamicTheme.Radius.small, style: .continuous)
                    .fill(backgroundColor)
            )
    }

    private var displayText: String {
        switch status.uppercased() {
        case "SCHEDULED": return "Scheduled"
        case "IN_PROGRESS": return "In Progress"
        case "COMPLETED": return "Completed"
        case "CANCELLED": return "Cancelled"
        case "PROPOSED": return "Proposed"
        case "CONFIRMED": return "Confirmed"
        case "RESCHEDULED": return "Rescheduled"
        case "NO_SHOW": return "No Show"
        default: return status.capitalized
        }
    }

    private var textColor: Color {
        switch status.uppercased() {
        case "COMPLETED", "CONFIRMED": return DynamicTheme.Colors.success
        case "IN_PROGRESS": return DynamicTheme.Colors.primary
        case "CANCELLED", "NO_SHOW": return DynamicTheme.Colors.error
        case "PROPOSED", "RESCHEDULED": return DynamicTheme.Colors.warning
        default: return DynamicTheme.Colors.textSecondary
        }
    }

    private var backgroundColor: Color {
        textColor.opacity(0.15)
    }
}

// MARK: - Current Time Indicator

/// A red line indicator showing current time on the calendar
public struct CurrentTimeIndicator: View {
    public let startHour: Int
    public let hourSlotHeight: CGFloat

    public init(startHour: Int = 6, hourSlotHeight: CGFloat = 60) {
        self.startHour = startHour
        self.hourSlotHeight = hourSlotHeight
    }

    private var currentOffset: CGFloat {
        let now = Date()
        let hour = Calendar.current.component(.hour, from: now)
        let minute = Calendar.current.component(.minute, from: now)

        let hourOffset = CGFloat(hour - startHour) * hourSlotHeight
        let minuteOffset = CGFloat(minute) / 60.0 * hourSlotHeight
        return hourOffset + minuteOffset
    }

    public var body: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(DynamicTheme.Colors.error)
                .frame(width: 10, height: 10)

            Rectangle()
                .fill(DynamicTheme.Colors.error)
                .frame(height: 2)
        }
        .offset(y: currentOffset)
        .padding(.leading, 60)
    }
}

// MARK: - Generic Calendar Event Card

/// A generic event card for displaying events on the hourly calendar
public struct CalendarEventCardView<Event: CalendarEventDisplayable>: View {
    public let event: Event
    public let topOffset: CGFloat
    public let height: CGFloat
    public let onTap: ((Event) -> Void)?
    public let onAction: ((Event) -> Void)?
    public let actionIcon: String?

    @State private var isPressed = false

    public init(
        event: Event,
        topOffset: CGFloat,
        height: CGFloat,
        onTap: ((Event) -> Void)? = nil,
        onAction: ((Event) -> Void)? = nil,
        actionIcon: String? = nil
    ) {
        self.event = event
        self.topOffset = topOffset
        self.height = height
        self.onTap = onTap
        self.onAction = onAction
        self.actionIcon = actionIcon
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(event.title)
                    .font(DynamicTheme.Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer()

                if let icon = actionIcon, onAction != nil {
                    Button(action: { onAction?(event) }) {
                        Image(systemName: icon)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                    }
                }
            }

            Text(event.subtitle)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
        }
        .padding(.horizontal, DynamicTheme.Spacing.sm)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: max(height - 4, 40))
        .background(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium, style: .continuous)
                .fill(event.status.color)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium, style: .continuous)
                .stroke(event.status.color.opacity(0.3), lineWidth: 1)
        )
        .offset(y: topOffset)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(DynamicTheme.Animations.quick, value: isPressed)
        .onTapGesture {
            onTap?(event)
        }
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
    }
}

// MARK: - Consultation Event Card

/// A specialized card for consultation events
public struct ConsultationEventCard: View {
    public let title: String
    public let clientName: String
    public let topOffset: CGFloat
    public let height: CGFloat
    public let onTap: (() -> Void)?

    public init(
        title: String = "Consultation",
        clientName: String,
        topOffset: CGFloat,
        height: CGFloat,
        onTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.clientName = clientName
        self.topOffset = topOffset
        self.height = height
        self.onTap = onTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 10))
                    .foregroundColor(.white)

                Text(title)
                    .font(DynamicTheme.Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }

            Text(clientName)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
        }
        .padding(.horizontal, DynamicTheme.Spacing.sm)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: max(height - 4, 40))
        .background(
            RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium, style: .continuous)
                .fill(Color.teal)
        )
        .offset(y: topOffset)
        .onTapGesture {
            onTap?()
        }
    }
}

// MARK: - Week Navigation Header

/// Navigation header for week-based calendar view
public struct WeekNavigationHeader: View {
    public let monthYearText: String
    public let onPreviousWeek: () -> Void
    public let onNextWeek: () -> Void

    public init(
        monthYearText: String,
        onPreviousWeek: @escaping () -> Void,
        onNextWeek: @escaping () -> Void
    ) {
        self.monthYearText = monthYearText
        self.onPreviousWeek = onPreviousWeek
        self.onNextWeek = onNextWeek
    }

    public var body: some View {
        HStack {
            Button(action: onPreviousWeek) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DynamicTheme.Colors.primary)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text(monthYearText)
                .font(DynamicTheme.Typography.title2)
                .foregroundColor(DynamicTheme.Colors.text)

            Spacer()

            Button(action: onNextWeek) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DynamicTheme.Colors.primary)
                    .frame(width: 44, height: 44)
            }
        }
    }
}

// MARK: - Selected Day Header

/// Header showing the selected day with item count and add button
public struct SelectedDayHeader: View {
    public let formattedDate: String
    public let itemCount: Int
    public let onAddTap: () -> Void

    public init(
        formattedDate: String,
        itemCount: Int,
        onAddTap: @escaping () -> Void
    ) {
        self.formattedDate = formattedDate
        self.itemCount = itemCount
        self.onAddTap = onAddTap
    }

    public var body: some View {
        HStack {
            Text(formattedDate)
                .font(DynamicTheme.Typography.bodyMedium)
                .foregroundColor(DynamicTheme.Colors.text)

            Spacer()

            if itemCount > 0 {
                Text("\(itemCount) item\(itemCount == 1 ? "" : "s")")
                    .font(DynamicTheme.Typography.caption)
                    .foregroundColor(DynamicTheme.Colors.textSecondary)
            }

            // Quick add button
            Button(action: onAddTap) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(DynamicTheme.Colors.primary)
            }
            .padding(.leading, DynamicTheme.Spacing.sm)
        }
    }
}

// MARK: - Calendar Loading View

/// Loading view for calendar content
public struct CalendarLoadingView: View {
    public let message: String

    public init(message: String = "Loading schedule...") {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: DynamicTheme.Spacing.md) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text(message)
                .font(DynamicTheme.Typography.body)
                .foregroundColor(DynamicTheme.Colors.textSecondary)
            Spacer()
        }
    }
}

// MARK: - Calendar Helpers

public extension Calendar {
    /// Returns the start of the week containing the given date
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }

    /// Returns an array of dates for the week containing the given date
    func weekDates(for date: Date) -> [Date] {
        let start = startOfWeek(for: date)
        return (0..<7).compactMap { self.date(byAdding: .day, value: $0, to: start) }
    }
}

// MARK: - Previews

#if DEBUG
struct CalendarComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Week Navigation Header
            WeekNavigationHeader(
                monthYearText: "December 2025",
                onPreviousWeek: {},
                onNextWeek: {}
            )
            .padding(.horizontal)

            // Calendar Day Cell
            HStack {
                CalendarDayCell(
                    date: Date(),
                    isSelected: true,
                    isToday: true,
                    hasItems: true,
                    weekdayName: "Fri",
                    dayNumber: "27",
                    itemCount: 3,
                    onTap: {}
                )

                CalendarDayCell(
                    date: Date(),
                    isSelected: false,
                    isToday: false,
                    hasItems: true,
                    weekdayName: "Sat",
                    dayNumber: "28",
                    itemCount: 1,
                    onTap: {}
                )

                CalendarDayCell(
                    date: Date(),
                    isSelected: false,
                    isToday: false,
                    hasItems: false,
                    weekdayName: "Sun",
                    dayNumber: "29",
                    itemCount: 0,
                    onTap: {}
                )
            }
            .padding(.horizontal)

            // Status Badges
            HStack {
                CalendarStatusBadge(status: "SCHEDULED")
                CalendarStatusBadge(status: "IN_PROGRESS")
                CalendarStatusBadge(status: "COMPLETED")
                CalendarStatusBadge(status: "CANCELLED")
            }

            // Hour Slot
            HourSlotView(
                hour: 9,
                date: Date(),
                height: 60,
                onTap: { _ in }
            )
            .frame(height: 60)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.vertical)
        .background(DynamicTheme.Colors.background)
    }
}
#endif

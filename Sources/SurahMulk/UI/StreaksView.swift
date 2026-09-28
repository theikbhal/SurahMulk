import SwiftUI

struct StreaksView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var progress: ProgressStore
    @State private var monthOffset = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                statCards
                calendarCard
                reminderCard
            }
            .padding(28)
            .frame(maxWidth: 860)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    private var statCards: some View {
        HStack(spacing: 16) {
            stat("Current streak", "\(progress.currentStreak)", "flame.fill", .orange)
            stat("Best streak", "\(progress.bestStreak)", "trophy.fill", .yellow)
            stat("Days read", "\(progress.doneCount)", "checkmark.circle.fill", .green)
            stat("Memorised", "\(progress.memorisedCount)/30", "brain.head.profile", .purple)
        }
    }

    private func stat(_ title: String, _ value: String, _ symbol: String, _ color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(RoundedRectangle(cornerRadius: 14).fill(.quaternary.opacity(0.25)))
    }

    private var month: Date {
        Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
    }

    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(monthTitle)
                    .font(.title3.bold())
                Spacer()
                Button {
                    monthOffset -= 1
                } label: { Image(systemName: "chevron.left") }
                    .buttonStyle(.bordered)
                Button {
                    monthOffset += 1
                } label: { Image(systemName: "chevron.right") }
                    .buttonStyle(.bordered)
                    .disabled(monthOffset >= 0)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                ForEach(0..<blankCount, id: \.self) { _ in
                    Color.clear.frame(height: 34)
                }
                ForEach(1...daysInMonth, id: \.self) { day in
                    dayCell(day)
                }
            }

            HStack(spacing: 16) {
                legendDot(.green, "read")
                legendDot(.orange, "today")
                legendDot(.clear, "not yet")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 14).fill(.quaternary.opacity(0.25)))
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color == .clear ? Color.secondary.opacity(0.2) : color)
                .frame(width: 10, height: 10)
            Text(label)
        }
    }

    private func dayCell(_ day: Int) -> some View {
        let key = keyFor(day: day)
        let done = progress.isDone(key)
        let isToday = key == progress.today
        return Text("\(day)")
            .font(.callout.weight(done ? .bold : .regular))
            .frame(width: 34, height: 34)
            .background(
                Circle().fill(
                    done ? Color.green.opacity(isToday ? 1 : 0.85) : Color.secondary.opacity(0.12)
                )
            )
            .foregroundStyle(done ? .white : .primary)
            .overlay(Circle().stroke(isToday ? Color.orange : .clear, lineWidth: 2))
    }

    private func keyFor(day: Int) -> String {
        let comps = Calendar.current.dateComponents([.year, .month], from: month)
        var c = DateComponents()
        c.year = comps.year
        c.month = comps.month
        c.day = day
        let date = Calendar.current.date(from: c) ?? Date()
        return ProgressStore.dayString(date)
    }

    private var monthTitle: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: month)
    }

    private var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: month)?.count ?? 30
    }

    private var blankCount: Int {
        let comps = Calendar.current.dateComponents([.year, .month], from: month)
        let first = Calendar.current.date(from: comps) ?? Date()
        return Calendar.current.component(.weekday, from: first) - 1
    }

    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Daily reminder", systemImage: "bell.badge.fill")
                .font(.title3.bold())

            Text("A notification at your chosen time keeps the chain going. The system delivers it even when the app is closed.")
                .font(.callout)
                .foregroundStyle(.secondary)

            Picker("Reminder", selection: $state.reminder) {
                ForEach(AppState.Reminder.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Spacer()
                if progress.todayDone {
                    Label("Today done", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Button("Mark today read") { progress.markTodayDone() }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 14).fill(.quaternary.opacity(0.25)))
    }
}

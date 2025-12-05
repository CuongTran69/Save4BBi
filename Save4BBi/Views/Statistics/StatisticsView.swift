//
//  StatisticsView.swift
//  MediFamily
//
//  Created by Cường Trần on 05/12/25.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MedicalVisit.visitDate, order: .reverse) private var visits: [MedicalVisit]
    @Query(sort: \FamilyMember.createdAt) private var members: [FamilyMember]
    @ObservedObject private var lang = LanguageManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Overview Cards
                    overviewSection
                    
                    // Visits by Member
                    if !members.isEmpty {
                        visitsByMemberSection
                    }
                    
                    // Common Conditions
                    if !conditionStats.isEmpty {
                        commonConditionsSection
                    }
                    
                    // Monthly Chart
                    if !monthlyStats.isEmpty {
                        monthlyChartSection
                    }
                    
                    // Recent Activity
                    if !visits.isEmpty {
                        recentActivitySection
                    }
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle(lang.localized("stats.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(lang.localized("button.done")) { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Overview Section
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(lang.localized("stats.overview"))
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                StatCard(
                    title: lang.localized("stats.total_visits"),
                    value: "\(visits.count)",
                    icon: "cross.case.fill",
                    color: Theme.Colors.primary
                )
                StatCard(
                    title: lang.localized("stats.total_members"),
                    value: "\(members.count)",
                    icon: "person.3.fill",
                    color: Theme.Colors.secondary
                )
                StatCard(
                    title: lang.localized("stats.this_month"),
                    value: "\(visitsThisMonth)",
                    icon: "calendar",
                    color: Theme.Colors.accent
                )
                StatCard(
                    title: lang.localized("stats.this_year"),
                    value: "\(visitsThisYear)",
                    icon: "chart.bar.fill",
                    color: Theme.Colors.info
                )
            }
        }
    }
    
    // MARK: - Visits by Member Section
    private var visitsByMemberSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(lang.localized("stats.visits_by_member"))
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
            
            VStack(spacing: Theme.Spacing.sm) {
                ForEach(memberStats) { stat in
                    MemberStatRow(stat: stat, maxCount: memberStats.first?.count ?? 1)
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.large)
            .shadow(color: Theme.Colors.shadow, radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Common Conditions Section
    private var commonConditionsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(lang.localized("stats.common_conditions"))
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
            
            VStack(spacing: Theme.Spacing.sm) {
                ForEach(conditionStats.prefix(5)) { stat in
                    ConditionStatRow(stat: stat, maxCount: conditionStats.first?.count ?? 1)
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.large)
            .shadow(color: Theme.Colors.shadow, radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Monthly Chart Section
    private var monthlyChartSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(lang.localized("stats.visits_by_month"))
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
            
            MonthlyBarChart(data: monthlyStats)
                .frame(height: 180)
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.cardBackground)
                .cornerRadius(Theme.CornerRadius.large)
                .shadow(color: Theme.Colors.shadow, radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(lang.localized("stats.recent_activity"))
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.text)
            
            VStack(spacing: 0) {
                ForEach(visits.prefix(5)) { visit in
                    RecentVisitRow(visit: visit, member: getMember(for: visit))
                    if visit.id != visits.prefix(5).last?.id {
                        Divider().padding(.leading, 50)
                    }
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.large)
            .shadow(color: Theme.Colors.shadow, radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Computed Properties
extension StatisticsView {
    private var visitsThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        return visits.filter { calendar.isDate($0.visitDate, equalTo: now, toGranularity: .month) }.count
    }
    
    private var visitsThisYear: Int {
        let calendar = Calendar.current
        let now = Date()
        return visits.filter { calendar.isDate($0.visitDate, equalTo: now, toGranularity: .year) }.count
    }
    
    private var memberStats: [MemberStat] {
        members.map { member in
            let count = visits.filter { $0.memberId == member.id }.count
            return MemberStat(member: member, count: count)
        }.sorted { $0.count > $1.count }
    }
    
    private var conditionStats: [ConditionStat] {
        var counts: [String: Int] = [:]
        for visit in visits {
            let condition = visit.condition.trimmingCharacters(in: .whitespacesAndNewlines)
            if !condition.isEmpty {
                counts[condition, default: 0] += 1
            }
        }
        return counts.map { ConditionStat(name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    private var monthlyStats: [MonthlyStat] {
        let calendar = Calendar.current
        let now = Date()
        var stats: [MonthlyStat] = []
        
        for i in (0..<6).reversed() {
            guard let date = calendar.date(byAdding: .month, value: -i, to: now) else { continue }
            let count = visits.filter { calendar.isDate($0.visitDate, equalTo: date, toGranularity: .month) }.count
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            stats.append(MonthlyStat(month: formatter.string(from: date), count: count))
        }
        return stats
    }
    
    private func getMember(for visit: MedicalVisit) -> FamilyMember? {
        guard let memberId = visit.memberId else { return nil }
        return members.first { $0.id == memberId }
    }
}

// MARK: - Data Models
struct MemberStat: Identifiable {
    let id = UUID()
    let member: FamilyMember
    let count: Int
}

struct ConditionStat: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
}

struct MonthlyStat: Identifiable {
    let id = UUID()
    let month: String
    let count: Int
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.text)

            Text(title)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.text.opacity(0.6))
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.large)
        .shadow(color: Theme.Colors.shadow, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Member Stat Row
struct MemberStatRow: View {
    let stat: MemberStat
    let maxCount: Int
    @ObservedObject private var lang = LanguageManager.shared

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Avatar
            Group {
                if let avatarData = stat.member.avatarData, let uiImage = UIImage(data: avatarData) {
                    Image(uiImage: uiImage).resizable().scaledToFill()
                } else {
                    Text(stat.member.avatarIcon).font(.system(size: 18))
                }
            }
            .frame(width: 36, height: 36)
            .background(Theme.Colors.primary.opacity(0.15))
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(stat.member.name)
                    .font(Theme.Typography.bodyBold)
                    .foregroundColor(Theme.Colors.text)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.Colors.primary.opacity(0.2))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.Colors.primary)
                            .frame(width: maxCount > 0 ? geo.size.width * CGFloat(stat.count) / CGFloat(maxCount) : 0, height: 8)
                    }
                }
                .frame(height: 8)
            }

            Text("\(stat.count)")
                .font(Theme.Typography.bodyBold)
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}

// MARK: - Condition Stat Row
struct ConditionStatRow: View {
    let stat: ConditionStat
    let maxCount: Int

    private let colors: [Color] = [
        Theme.Colors.primary,
        Theme.Colors.secondary,
        Theme.Colors.accent,
        Theme.Colors.info,
        Theme.Colors.warning
    ]

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Circle()
                .fill(colors[abs(stat.name.hashValue) % colors.count])
                .frame(width: 12, height: 12)

            Text(stat.name)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.text)
                .lineLimit(1)

            Spacer()

            // Mini bar
            RoundedRectangle(cornerRadius: 4)
                .fill(colors[abs(stat.name.hashValue) % colors.count].opacity(0.3))
                .frame(width: 60, height: 8)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colors[abs(stat.name.hashValue) % colors.count])
                        .frame(width: maxCount > 0 ? 60 * CGFloat(stat.count) / CGFloat(maxCount) : 0)
                }

            Text("\(stat.count)")
                .font(Theme.Typography.bodyBold)
                .foregroundColor(Theme.Colors.text.opacity(0.7))
                .frame(width: 30, alignment: .trailing)
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}

// MARK: - Monthly Bar Chart
struct MonthlyBarChart: View {
    let data: [MonthlyStat]

    private var maxValue: Int {
        data.map { $0.count }.max() ?? 1
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: Theme.Spacing.md) {
            ForEach(data) { stat in
                VStack(spacing: Theme.Spacing.sm) {
                    Text("\(stat.count)")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.text.opacity(0.7))

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Theme.Colors.primary, Theme.Colors.accent],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: maxValue > 0 ? max(20, 120 * CGFloat(stat.count) / CGFloat(maxValue)) : 20)

                    Text(stat.month)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.text.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Recent Visit Row
struct RecentVisitRow: View {
    let visit: MedicalVisit
    let member: FamilyMember?

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Date circle
            VStack(spacing: 2) {
                Text(dayString)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.primary)
                Text(monthString)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Theme.Colors.text.opacity(0.6))
            }
            .frame(width: 40, height: 40)
            .background(Theme.Colors.primary.opacity(0.1))
            .cornerRadius(Theme.CornerRadius.small)

            VStack(alignment: .leading, spacing: 4) {
                Text(visit.displayTitle)
                    .font(Theme.Typography.bodyBold)
                    .foregroundColor(Theme.Colors.text)
                    .lineLimit(1)

                HStack(spacing: Theme.Spacing.sm) {
                    if let member = member {
                        Text(member.name)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.primary)
                    }

                    if !visit.condition.isEmpty && visit.condition != visit.displayTitle {
                        Text("•")
                            .foregroundColor(Theme.Colors.text.opacity(0.3))
                        Text(visit.condition)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.text.opacity(0.6))
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            if visit.hasPhotos {
                Image(systemName: "photo.fill")
                    .font(.caption)
                    .foregroundColor(Theme.Colors.accent)
            }
        }
        .padding(.vertical, Theme.Spacing.sm)
    }

    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: visit.visitDate)
    }

    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: visit.visitDate)
    }
}

// MARK: - Preview
#Preview {
    StatisticsView()
        .modelContainer(for: [MedicalVisit.self, FamilyMember.self], inMemory: true)
}


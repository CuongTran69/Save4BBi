//
//  FamilyMembersView.swift
//  MediFamily
//
//  Created by Cường Trần on 05/12/25.
//

import SwiftUI
import SwiftData

struct FamilyMembersView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FamilyMember.createdAt) private var members: [FamilyMember]
    @Query private var allVisits: [MedicalVisit]
    @ObservedObject private var lang = LanguageManager.shared
    @ObservedObject private var memberManager = MemberManager.shared

    @State private var showingAddMember = false
    @State private var memberToEdit: FamilyMember?
    @State private var memberToDelete: FamilyMember?
    @State private var showingDeleteSheet = false
    @State private var memberVisitCount = 0

    private let photoService = PhotoService.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.md) {
                    if members.isEmpty {
                        emptyStateView
                    } else {
                        memberListView
                    }
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle(lang.localized("member.profiles"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.localized("button.done")) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddMember = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMember) {
                AddMemberView()
            }
            .sheet(item: $memberToEdit) { member in
                AddMemberView(memberToEdit: member)
            }
            .confirmationDialog(
                lang.localized("member.delete.title"),
                isPresented: $showingDeleteSheet,
                titleVisibility: .visible
            ) {
                if memberVisitCount > 0 {
                    Button(lang.localized("member.delete.keep_visits"), role: .none) {
                        if let member = memberToDelete {
                            deleteMember(member, deleteVisits: false)
                        }
                    }
                    Button(lang.localized("member.delete.with_visits"), role: .destructive) {
                        if let member = memberToDelete {
                            deleteMember(member, deleteVisits: true)
                        }
                    }
                } else {
                    Button(lang.localized("button.delete"), role: .destructive) {
                        if let member = memberToDelete {
                            deleteMember(member, deleteVisits: false)
                        }
                    }
                }
                Button(lang.localized("button.cancel"), role: .cancel) { }
            } message: {
                if memberVisitCount > 0 {
                    Text(lang.localized("member.delete.has_visits").replacingOccurrences(of: "{count}", with: "\(memberVisitCount)"))
                } else {
                    Text(lang.localized("member.delete.message"))
                }
            }
        }
    }

    // MARK: - Helper Functions
    private func getVisitCount(for member: FamilyMember) -> Int {
        allVisits.filter { $0.memberId == member.id }.count
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()

            // Illustration with animated circles
            ZStack {
                // Background decorative circles
                Circle()
                    .fill(Theme.Colors.accent.opacity(0.2))
                    .frame(width: 200, height: 200)

                Circle()
                    .fill(Theme.Colors.secondary.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .offset(x: 40, y: -30)

                Circle()
                    .fill(Theme.Colors.primary.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .offset(x: -50, y: 40)

                // Family icons arrangement
                VStack(spacing: -10) {
                    HStack(spacing: 20) {
                        familyMemberIcon("👶", size: 40, bgColor: Theme.Colors.accent)
                        familyMemberIcon("👨", size: 50, bgColor: Theme.Colors.primary)
                        familyMemberIcon("👩", size: 50, bgColor: Theme.Colors.secondary)
                    }
                    HStack(spacing: 30) {
                        familyMemberIcon("👴", size: 40, bgColor: Theme.Colors.warning.opacity(0.6))
                        familyMemberIcon("👧", size: 35, bgColor: Theme.Colors.info)
                    }
                }
            }
            .frame(height: 200)

            // Text content
            VStack(spacing: Theme.Spacing.sm) {
                Text(lang.localized("member.empty.title"))
                    .font(Theme.Typography.title2)
                    .foregroundColor(Theme.Colors.text)
                    .multilineTextAlignment(.center)

                Text(lang.localized("member.empty.subtitle"))
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.text.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
            }

            // CTA Button with gradient
            Button {
                showingAddMember = true
            } label: {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "person.badge.plus")
                        .font(.title3)
                    Text(lang.localized("member.add.first"))
                        .font(Theme.Typography.bodyBold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.vertical, Theme.Spacing.md)
                .background(
                    LinearGradient(
                        colors: [Theme.Colors.primary, Theme.Colors.accent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(Theme.CornerRadius.round)
                .shadow(color: Theme.Colors.primary.opacity(0.4), radius: 10, x: 0, y: 5)
            }

            // Quick tips
            VStack(spacing: Theme.Spacing.sm) {
                tipRow(icon: "heart.fill", text: lang.localized("member.tip.1"), color: Theme.Colors.secondary)
                tipRow(icon: "doc.text.fill", text: lang.localized("member.tip.2"), color: Theme.Colors.primary)
                tipRow(icon: "bell.fill", text: lang.localized("member.tip.3"), color: Theme.Colors.accent)
            }
            .padding(.top, Theme.Spacing.lg)

            Spacer()
        }
        .padding(Theme.Spacing.md)
    }

    private func familyMemberIcon(_ emoji: String, size: CGFloat, bgColor: Color) -> some View {
        Text(emoji)
            .font(.system(size: size * 0.5))
            .frame(width: size, height: size)
            .background(bgColor.opacity(0.8))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 3))
            .shadow(color: bgColor.opacity(0.5), radius: 5, x: 0, y: 3)
    }

    private func tipRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
                .background(color.opacity(0.15))
                .clipShape(Circle())

            Text(text)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.text.opacity(0.7))

            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }
    
    // MARK: - Member List
    private var memberListView: some View {
        LazyVStack(spacing: Theme.Spacing.md) {
            ForEach(members) { member in
                MemberRowView(
                    member: member,
                    isSelected: memberManager.isSelected(member),
                    onTap: {
                        memberManager.selectMember(member)
                        dismiss()
                    },
                    onEdit: { memberToEdit = member },
                    onDelete: {
                        memberToDelete = member
                        memberVisitCount = getVisitCount(for: member)
                        showingDeleteSheet = true
                    }
                )
            }
        }
    }

    private func deleteMember(_ member: FamilyMember, deleteVisits: Bool) {
        // Clear selection if this member is selected
        if memberManager.isSelected(member) {
            memberManager.clearSelection()
        }

        if deleteVisits {
            // Delete all visits associated with this member
            let memberVisits = allVisits.filter { $0.memberId == member.id }
            for visit in memberVisits {
                // Delete photos from file system
                Task {
                    for filename in visit.photoFilePaths {
                        _ = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                            _ = photoService.deletePhoto(filename: filename)
                                .subscribe(
                                    onNext: { continuation.resume(returning: ()) },
                                    onError: { error in continuation.resume(throwing: error) }
                                )
                        }
                    }
                }
                modelContext.delete(visit)
            }
        } else {
            // Just unlink visits from member (set memberId to nil)
            let memberVisits = allVisits.filter { $0.memberId == member.id }
            for visit in memberVisits {
                visit.memberId = nil
            }
        }

        // Delete the member
        modelContext.delete(member)
        try? modelContext.save()
    }
}

// MARK: - Member Row View
struct MemberRowView: View {
    let member: FamilyMember
    let isSelected: Bool
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @ObservedObject private var lang = LanguageManager.shared
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.md) {
                avatarView
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(member.name)
                            .font(Theme.Typography.bodyBold)
                            .foregroundColor(Theme.Colors.text)
                        
                        memberTypeBadge
                    }
                    
                    HStack(spacing: Theme.Spacing.sm) {
                        Text(member.age)
                        Text("•").foregroundColor(Theme.Colors.text.opacity(0.3))
                        Text(member.bloodType.rawValue)
                        Text("•").foregroundColor(Theme.Colors.text.opacity(0.3))
                        Text(relationshipLabel)
                    }
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.text.opacity(0.6))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.Colors.primary)
                        .font(.title2)
                }
                
                Menu {
                    Button { onEdit() } label: {
                        Label(lang.localized("button.edit"), systemImage: "pencil")
                    }
                    Button(role: .destructive) { onDelete() } label: {
                        Label(lang.localized("button.delete"), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(Theme.Colors.text.opacity(0.5))
                        .padding(8)
                }
            }
            .padding(Theme.Spacing.md)
            .background(isSelected ? Theme.Colors.primary.opacity(0.1) : Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(isSelected ? Theme.Colors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var avatarView: some View {
        Group {
            if let avatarData = member.avatarData, let uiImage = UIImage(data: avatarData) {
                Image(uiImage: uiImage).resizable().scaledToFill()
            } else {
                Text(member.avatarIcon).font(.system(size: 28))
            }
        }
        .frame(width: 50, height: 50)
        .background(Theme.Colors.primary.opacity(0.15))
        .clipShape(Circle())
    }
    
    private var memberTypeBadge: some View {
        Text(memberTypeLabel)
            .font(.system(size: 10, weight: .medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(memberTypeColor.opacity(0.2))
            .foregroundColor(memberTypeColor)
            .cornerRadius(4)
    }
    
    private var memberTypeLabel: String {
        switch member.memberType {
        case .child: return lang.localized("member.type.child")
        case .adult: return lang.localized("member.type.adult")
        case .senior: return lang.localized("member.type.senior")
        }
    }
    
    private var memberTypeColor: Color {
        switch member.memberType {
        case .child: return .blue
        case .adult: return .green
        case .senior: return .orange
        }
    }
    
    private var relationshipLabel: String {
        switch member.relationship {
        case .father: return lang.localized("relation.father")
        case .mother: return lang.localized("relation.mother")
        case .child: return lang.localized("relation.child")
        case .grandfather: return lang.localized("relation.grandfather")
        case .grandmother: return lang.localized("relation.grandmother")
        case .spouse: return lang.localized("relation.spouse")
        case .sibling: return lang.localized("relation.sibling")
        case .other: return lang.localized("relation.other")
        }
    }
}


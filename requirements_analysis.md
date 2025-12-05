# 🎯 PHASE 1: REQUIREMENTS ANALYSIS

**Project Name**: MediFamily (Family Health Records Tracker)
**Platform**: iOS Mobile Application
**Technology Stack**: SwiftUI, SwiftData, Swift
**Target Users**: Families tracking medical visits for all members (children, adults, seniors)
**Core Purpose**: Secure, user-friendly app for organizing and searching medical visit photos for the whole family
**Date**: 2025-12-05
**Previous Name**: Save4BBi (renamed to support entire family)

---

## 📋 PROJECT OVERVIEW

### Security & Privacy Considerations
Based on HIPAA best practices research (even though this is a personal app, security is critical):
- **Data Encryption**: All photos and medical data encrypted at rest (AES-256-GCM)
- **Local Storage**: Keep data on-device to avoid cloud privacy concerns (unless explicitly opted-in)
- **Biometric Authentication**: Face ID/Touch ID for app access
- **No Third-Party Access**: Ensure no unauthorized data sharing

### Technology Stack Validation
- **SwiftUI**: Modern, declarative UI framework (iOS 16+)
- **SwiftData**: Local database for metadata storage
- **PhotoKit**: For photo management and access
- **CryptoKit**: For encryption capabilities
- **RxSwift**: For reactive data flow

### UI/UX Best Practices for Medical Apps
- **Family-Friendly Design**: Soft colors, rounded corners, intuitive icons
- **Easy Navigation**: Simple, intuitive interface for quick access
- **Visual Hierarchy**: Clear organization by date, condition, member, or visit
- **Accessibility**: Support for larger text, VoiceOver
- **Multi-Language**: English and Vietnamese support

---

## 📝 FUNCTIONAL REQUIREMENTS (EARS Notation)

### FR-1: Photo Management
- **FR-1.1**: WHEN a user opens the app THE SYSTEM SHALL display all medical visit photo albums in a grid/list view
- **FR-1.2**: WHEN a user taps "Add New Visit" THE SYSTEM SHALL allow capturing or selecting multiple photos from the camera/gallery
- **FR-1.3**: WHEN a user selects photos THE SYSTEM SHALL prompt for visit metadata (date, title, condition/illness, doctor name, notes)
- **FR-1.4**: WHEN a user saves a visit THE SYSTEM SHALL store photos with encrypted metadata locally
- **FR-1.5**: WHEN a user views a visit album THE SYSTEM SHALL display all photos with associated metadata
- **FR-1.6**: WHEN a user long-presses a visit THE SYSTEM SHALL provide options to edit, delete, or share

### FR-2: Search & Filter Functionality
- **FR-2.1**: WHEN a user enters text in the search bar THE SYSTEM SHALL filter visits by illness/condition name, title, doctor name, or notes
- **FR-2.2**: WHEN a user selects a date filter THE SYSTEM SHALL display visits within the selected date range
- **FR-2.3**: WHEN a user applies multiple filters THE SYSTEM SHALL combine filters using AND logic
- **FR-2.4**: WHEN a user clears filters THE SYSTEM SHALL restore the full visit list
- **FR-2.5**: WHEN a user taps a search result THE SYSTEM SHALL navigate to the detailed visit view

### FR-3: Data Organization
- **FR-3.1**: WHEN a user views the home screen THE SYSTEM SHALL organize visits by most recent first (default)
- **FR-3.2**: WHEN a user selects sort options THE SYSTEM SHALL allow sorting by date (newest/oldest), condition name (A-Z), or frequency
- **FR-3.3**: WHEN a user creates tags/categories THE SYSTEM SHALL allow grouping visits by custom categories (e.g., "Vaccinations", "Checkups", "Emergencies")
- **FR-3.4**: WHEN a user views statistics THE SYSTEM SHALL display visit frequency, common conditions, and timeline visualization

### FR-4: Security & Privacy
- **FR-4.1**: WHEN a user first launches the app THE SYSTEM SHALL require biometric authentication setup (Face ID/Touch ID)
- **FR-4.2**: WHEN a user reopens the app after backgrounding THE SYSTEM SHALL require biometric authentication
- **FR-4.3**: WHEN a user stores photos THE SYSTEM SHALL encrypt all data using AES-256 encryption
- **FR-4.4**: WHEN a user enables cloud backup (optional) THE SYSTEM SHALL use iCloud with end-to-end encryption

### FR-5: Enhanced Features
- **FR-5.1**: WHEN a user adds a visit THE SYSTEM SHALL allow attaching PDF documents (lab results, prescriptions)
- **FR-5.2**: WHEN a user views a visit THE SYSTEM SHALL display a timeline of all visits for that condition
- **FR-5.3**: WHEN a user sets reminders THE SYSTEM SHALL send notifications for follow-up appointments
- **FR-5.4**: WHEN a user exports data THE SYSTEM SHALL generate a PDF report with photos and metadata
- **FR-5.5**: WHEN a user adds voice notes THE SYSTEM SHALL allow recording and playback of audio memos

### FR-6: Family Member Management ✅ IMPLEMENTED
- **FR-6.1**: WHEN a user has multiple family members THE SYSTEM SHALL allow creating separate profiles for each member
- **FR-6.2**: WHEN a user selects a member profile THE SYSTEM SHALL display only that member's medical visits
- **FR-6.3**: WHEN a user adds a member THE SYSTEM SHALL collect:
  - Basic: name, date of birth, photo, gender, blood type, relationship
  - Member Type: child 👶, adult 👨, senior 👴
  - Adult/Senior fields: height, weight, chronic conditions, medications, insurance ID
- **FR-6.4**: WHEN a user views a member profile THE SYSTEM SHALL display health summary and visit statistics
- **FR-6.5**: WHEN a user views a member THE SYSTEM SHALL display BMI calculation (for adults/seniors with height & weight)

---

## 🎨 NON-FUNCTIONAL REQUIREMENTS

### NFR-1: Performance
- **NFR-1.1**: WHEN a user opens the app THE SYSTEM SHALL load the home screen within 1 second
- **NFR-1.2**: WHEN a user searches THE SYSTEM SHALL return results within 500ms for up to 1000 visits
- **NFR-1.3**: WHEN a user scrolls through photos THE SYSTEM SHALL maintain 60fps smooth scrolling

### NFR-2: Usability
- **NFR-2.1**: WHEN a user interacts with the UI THE SYSTEM SHALL use family-friendly design elements (soft colors, rounded corners, intuitive icons)
- **NFR-2.2**: WHEN a user navigates THE SYSTEM SHALL provide clear visual feedback for all interactions
- **NFR-2.3**: WHEN a user needs help THE SYSTEM SHALL provide contextual tooltips and onboarding
- **NFR-2.4**: WHEN a user changes language THE SYSTEM SHALL support runtime language switching (EN/VI)

### NFR-3: Security
- **NFR-3.1**: WHEN a user stores data THE SYSTEM SHALL use iOS Keychain for encryption key storage
- **NFR-3.2**: WHEN a user takes screenshots THE SYSTEM SHALL blur sensitive information in app switcher
- **NFR-3.3**: WHEN a user shares data THE SYSTEM SHALL require explicit confirmation

### NFR-4: Compatibility
- **NFR-4.1**: WHEN deployed THE SYSTEM SHALL support iOS 16.0 and above
- **NFR-4.2**: WHEN running THE SYSTEM SHALL support iPhone and iPad with adaptive layouts
- **NFR-4.3**: WHEN using THE SYSTEM SHALL support Dark Mode and Light Mode

### NFR-5: Data Management
- **NFR-5.1**: WHEN a user stores photos THE SYSTEM SHALL compress images to optimize storage while maintaining quality
- **NFR-5.2**: WHEN a user backs up data THE SYSTEM SHALL support local export to Files app
- **NFR-5.3**: WHEN a user deletes data THE SYSTEM SHALL provide confirmation and allow undo within 30 seconds

---

## 🎯 USER STORIES

### Epic 1: Core Photo Management
1. **As a parent**, I want to quickly add photos from a doctor visit, so that I can document my child's medical history immediately
2. **As a parent**, I want to organize photos by visit date and condition, so that I can easily find specific medical records
3. **As a parent**, I want to add notes and details to each visit, so that I remember important information the doctor shared

### Epic 2: Search & Discovery
4. **As a parent**, I want to search by illness name, so that I can find all visits related to a specific condition
5. **As a parent**, I want to filter by date range, so that I can review visits from a specific time period
6. **As a parent**, I want to see a timeline view, so that I can visualize my child's medical history

### Epic 3: Enhanced Functionality
7. **As a parent**, I want to attach lab results and prescriptions, so that I have all medical documents in one place
8. **As a parent**, I want to set follow-up reminders, so that I don't miss important appointments
9. **As a parent**, I want to export visit reports, so that I can share them with doctors or family members

### Epic 4: Family Member Support ✅ IMPLEMENTED
10. **As a family member**, I want separate profiles for each person (children, adults, seniors), so that I can manage their medical records independently
11. **As a family member**, I want to see health statistics for each person, so that I can track their overall health trends
12. **As a family member**, I want to record relationship types (Father, Mother, Child, Grandparents, etc.), so that I can organize by family structure
13. **As an adult/senior**, I want to track chronic conditions and medications, so that I have a complete health profile

---

## 🔒 CONSTRAINTS & ASSUMPTIONS

### Technical Constraints
- **TC-1**: Must use SwiftUI (iOS 16+) as specified
- **TC-2**: Local-first architecture (offline-capable)
- **TC-3**: No backend server required (all data stored locally)
- **TC-4**: Must comply with iOS App Store guidelines

### Business Constraints
- **BC-1**: Single developer project (simple, maintainable codebase)
- **BC-2**: No external dependencies on paid services
- **BC-3**: Free app with optional premium features (future consideration)

### Assumptions
- **A-1**: Users have iOS devices with biometric authentication capability
- **A-2**: Users want privacy-first solution (local storage preferred)
- **A-3**: Users are comfortable with basic photo organization concepts
- **A-4**: Users may have 1-3 children on average
- **A-5**: Average of 10-50 medical visits per child per year

---

## 🎨 UI/UX DESIGN PRINCIPLES

### Design Language: "Cute & Caring"

#### 1. Color Palette
- **Primary**: Soft pastel blue (#A8D8EA) - calming, medical
- **Secondary**: Warm peach (#FFB6B9) - friendly, caring
- **Accent**: Mint green (#B4E7CE) - fresh, healthy
- **Background**: Cream white (#FFF9F0) - soft, easy on eyes
- **Text**: Charcoal gray (#4A4A4A) - readable, not harsh

#### 2. Typography
- **Headers**: SF Pro Rounded (playful, friendly)
- **Body**: SF Pro Text (readable, standard)
- **Size**: Support Dynamic Type for accessibility

#### 3. Visual Elements
- Rounded corners (16px radius) for all cards
- Soft shadows for depth
- Playful icons (SF Symbols with custom tints)
- Smooth animations (spring animations for interactions)

#### 4. Layout Patterns
- Grid view for album overview (2 columns on iPhone, 3-4 on iPad)
- Card-based design for visit entries
- Bottom sheet for quick actions
- Floating action button for "Add Visit"

---

## 🚀 PROPOSED FEATURE SET

### ✅ MVP Features (Phase 1) - COMPLETED
1. ✅ Add/Edit/Delete medical visit photos
2. ✅ Basic metadata (date, title, condition, notes)
3. ✅ Search by text (condition, title, notes)
4. ✅ Filter by date range and tags
5. ✅ Grid/List view toggle
6. ✅ Biometric authentication (Face ID/Touch ID)
7. ✅ Local encrypted storage (AES-256-GCM)
8. ✅ Multi-language support (EN/VI runtime switching)

### ✅ Phase 2 Features - COMPLETED (MediFamily Update)
1. ✅ **Family Member Profiles** - Support for children, adults, and seniors
2. ✅ **Member Types** - child 👶, adult 👨, senior 👴 with appropriate icons
3. ✅ **Relationships** - Father, Mother, Child, Grandparents, Spouse, Sibling
4. ✅ **Adult/Senior Fields** - Height, Weight, BMI, Chronic conditions, Medications, Insurance ID
5. ✅ **Member Filtering** - Filter visits by family member
6. ✅ **New Branding** - MediFamily with family-oriented design

### 🔮 Future Enhancements (Phase 3+)
1. 🔮 PDF attachment support (lab results, prescriptions)
2. 🔮 Voice notes
3. 🔮 Reminder notifications for follow-ups
4. 🔮 Export to PDF report
5. 🔮 iCloud sync (optional backup)
6. 🔮 Health statistics dashboard
7. 🔮 Timeline visualization
8. 🔮 Share with doctors/family members
9. 🔮 Apple Health integration

---

## ✅ REQUIREMENTS VALIDATION CHECKLIST

- [x] All requirements use EARS notation format
- [x] Security and privacy considerations researched and documented
- [x] SwiftUI technology stack validated
- [x] UI/UX best practices for medical apps incorporated
- [x] Simplicity principles applied (MVP-focused)
- [x] User stories trace to functional requirements
- [x] Non-functional requirements defined
- [x] Constraints and assumptions documented
- [x] No overengineering (local-first, simple architecture)

---

## 📊 SUCCESS CRITERIA

The requirements analysis is complete when:
1. ✅ All functional requirements defined in EARS notation
2. ✅ Security and privacy requirements validated through research
3. ✅ UI/UX design principles established
4. ✅ MVP scope clearly separated from future enhancements
5. ✅ Technical constraints and assumptions documented
6. ✅ User approval obtained

---

## 📁 PROJECT STRUCTURE (MediFamily)

```
MediFamily/
├── MediFamilyApp.swift           # App entry point
├── ContentView.swift
├── Models/
│   ├── FamilyMember.swift        # Member model with MemberType, Relationship enums
│   └── MedicalVisit.swift        # Visit model linked to memberId
├── Views/
│   ├── SplashScreenView.swift
│   ├── Home/HomeView.swift
│   ├── AddVisit/AddVisitView.swift
│   ├── EditVisit/EditVisitView.swift
│   ├── VisitDetail/VisitDetailView.swift
│   ├── FamilyMembers/
│   │   ├── FamilyMembersView.swift
│   │   └── AddMemberView.swift
│   ├── Settings/SettingsView.swift
│   └── Components/
├── Services/
│   ├── BiometricService.swift
│   ├── EncryptionService.swift
│   ├── LanguageManager.swift     # EN/VI localization
│   ├── MemberManager.swift       # Member selection management
│   └── PhotoService.swift
└── Utilities/
    └── Theme.swift
```

---

## 🎯 IMPLEMENTATION STATUS

| Feature | Status | Notes |
|---------|--------|-------|
| Photo Management | ✅ Done | Add, view, delete with encryption |
| Search & Filter | ✅ Done | By text, date, tags |
| Biometric Auth | ✅ Done | Face ID/Touch ID |
| Encryption | ✅ Done | AES-256-GCM |
| Multi-language | ✅ Done | EN/VI runtime toggle |
| Family Members | ✅ Done | Child/Adult/Senior types |
| Member Relationships | ✅ Done | Father, Mother, etc. |
| Adult Health Fields | ✅ Done | Height, Weight, BMI, etc. |
| Member Filtering | ✅ Done | Filter visits by member |

---

**🎯 PHASE 2 COMPLETE - MEDIFAMILY READY**

The app has been successfully transformed from Save4BBi (children-only) to MediFamily (whole family support).


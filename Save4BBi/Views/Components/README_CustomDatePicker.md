# CustomDatePicker Component

## 📅 Overview

**CustomDatePicker** is a modern, user-friendly date picker component for MediFamily app. It provides a beautiful, intuitive interface for selecting dates and times with smooth animations and localization support.

## ✨ Features

- ✅ **Two Modes**: Date-only or Date+Time selection
- ✅ **Expandable UI**: Click to expand/collapse picker
- ✅ **Date Range Support**: Restrict to past, future, or custom ranges
- ✅ **Localization**: Automatic EN/VI language support
- ✅ **Beautiful Design**: Matches MediFamily theme with soft colors
- ✅ **Smooth Animations**: Spring animations for expand/collapse
- ✅ **Cancel/Done Actions**: User can cancel or confirm selection
- ✅ **Visual Feedback**: Border highlight when active

## 🎨 UI Design

### Collapsed State
```
┌─────────────────────────────────────────┐
│  📅  December 9, 2025              ▼   │
└─────────────────────────────────────────┘
```

### Expanded State
```
┌─────────────────────────────────────────┐
│  📅  December 9, 2025              ▲   │  ← Highlighted border
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│                                         │
│        [Calendar Picker UI]             │
│                                         │
│  ┌──────────┐        ┌──────────┐      │
│  │  Cancel  │        │   Done   │      │
│  └──────────┘        └──────────┘      │
└─────────────────────────────────────────┘
```

## 📖 Usage

### Basic Date Picker

```swift
@State private var visitDate = Date()

CustomDatePicker(
    "Visit Date",
    selection: $visitDate,
    mode: .date
)
```

### Date Picker with Past-Only Range

```swift
@State private var birthDate = Date()

CustomDatePicker(
    "Date of Birth",
    selection: $birthDate,
    mode: .date,
    in: ...Date()  // Only past dates
)
```

### Date and Time Picker with Future-Only Range

```swift
@State private var reminderDate = Date()

CustomDatePicker(
    "Reminder Time",
    selection: $reminderDate,
    mode: .dateAndTime,
    in: Date()...  // Only future dates
)
```

### Without Label

```swift
CustomDatePicker(
    selection: $date,
    mode: .date,
    showLabel: false
)
```

## 🔧 Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `String?` | `nil` | Label text above the picker |
| `selection` | `Binding<Date>` | Required | Binding to selected date |
| `mode` | `Mode` | `.date` | `.date` or `.dateAndTime` |
| `dateRange` | `ClosedRange<Date>?` | `nil` | Optional date range constraint |
| `showLabel` | `Bool` | `true` | Show/hide the label |

## 🎯 Mode Options

### `.date`
- Shows only date selection (day, month, year)
- Format: "December 9, 2025"
- Use for: Visit dates, birth dates, etc.

### `.dateAndTime`
- Shows date and time selection
- Format: "Dec 9, 2025 at 2:30 PM"
- Use for: Reminders, appointments, etc.

## 🌍 Localization

The component automatically uses the current app language:

**English:**
- "December 9, 2025"
- "Dec 9, 2025 at 2:30 PM"

**Vietnamese:**
- "9 tháng 12, 2025"
- "9 thg 12, 2025 lúc 14:30"

## 🎨 Theme Integration

CustomDatePicker uses MediFamily's theme system:

- **Primary Color**: Soft blue (#A8D8EA) for icons and highlights
- **Card Background**: White for picker container
- **Text Color**: Charcoal gray (#4A4A4A)
- **Corner Radius**: Medium (12px) for button, Large (16px) for picker
- **Shadow**: Subtle shadow for depth
- **Animation**: Spring animation (0.3s, damping 0.7)

## 📱 Replaced Components

CustomDatePicker has replaced the default DatePicker in:

1. ✅ **AddVisitView** - Visit date selection
2. ✅ **EditVisitView** - Visit date editing
3. ✅ **AddMemberView** - Date of birth selection
4. ✅ **ReminderSheet** - Custom reminder date/time

## 🔄 Migration Guide

### Before (Old DatePicker)
```swift
VStack(alignment: .leading, spacing: 8) {
    Text("Visit Date")
        .font(.subheadline)
        .foregroundColor(.gray)
    
    DatePicker("", selection: $visitDate, displayedComponents: .date)
        .datePickerStyle(.compact)
        .labelsHidden()
}
```

### After (CustomDatePicker)
```swift
CustomDatePicker(
    "Visit Date",
    selection: $visitDate,
    mode: .date
)
```

**Benefits:**
- ✅ Less code (3 lines vs 9 lines)
- ✅ Consistent UI across app
- ✅ Better UX with expand/collapse
- ✅ Cancel/Done actions
- ✅ Automatic localization

## 🎬 Demo

Run `CustomDatePickerDemo` view to see all variations:

```swift
CustomDatePickerDemo()
```

## 🐛 Known Issues

None currently.

## 🚀 Future Enhancements

- [ ] Add preset quick selections (Today, Tomorrow, Next Week)
- [ ] Add time-only mode
- [ ] Add custom date format option
- [ ] Add accessibility labels
- [ ] Add haptic feedback

---

**Created:** December 9, 2025  
**Author:** Cường Trần  
**Version:** 1.0


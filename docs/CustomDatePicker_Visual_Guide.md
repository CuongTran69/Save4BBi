# CustomDatePicker Visual Guide

## 🎨 UI States

### State 1: Collapsed (Default)

```
┌─────────────────────────────────────────────────────────┐
│  📅  December 9, 2025                              ▼   │
└─────────────────────────────────────────────────────────┘
```

**Visual Elements:**
- Calendar icon (📅) in primary blue color
- Formatted date text in body font
- Chevron down icon (▼) in primary blue
- White background with subtle shadow
- Rounded corners (12px)

**Interaction:**
- Tap anywhere to expand

---

### State 2: Expanded (Active)

```
┌─────────────────────────────────────────────────────────┐
│  📅  December 9, 2025                              ▲   │ ← Blue border (2px)
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                                                         │
│              December 2025                              │
│                                                         │
│   Sun  Mon  Tue  Wed  Thu  Fri  Sat                    │
│                              1    2                     │
│    3    4    5    6    7    8    9  ← Selected         │
│   10   11   12   13   14   15   16                     │
│   17   18   19   20   21   22   23                     │
│   24   25   26   27   28   29   30                     │
│   31                                                    │
│                                                         │
│  ┌──────────────────┐      ┌──────────────────┐        │
│  │     Cancel       │      │      Done        │        │
│  │   (Gray bg)      │      │   (Blue bg)      │        │
│  └──────────────────┘      └──────────────────┘        │
└─────────────────────────────────────────────────────────┘
```

**Visual Elements:**
- Header button with blue border highlight
- Chevron up icon (▲)
- Graphical calendar picker
- Selected date highlighted in blue
- Cancel button (gray background)
- Done button (blue background, white text)
- Larger shadow for depth
- Rounded corners (16px for picker)

**Interaction:**
- Tap calendar to select date
- Tap Cancel to close without saving
- Tap Done to save and close
- Tap header to collapse

---

### State 3: Date and Time Mode

```
┌─────────────────────────────────────────────────────────┐
│  🕐  Dec 9, 2025 at 2:30 PM                        ▼   │
└─────────────────────────────────────────────────────────┘
```

**When Expanded:**

```
┌─────────────────────────────────────────────────────────┐
│  🕐  Dec 9, 2025 at 2:30 PM                        ▲   │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                                                         │
│              December 2025                              │
│   [Calendar Grid]                                       │
│                                                         │
│              2:30 PM                                    │
│   ┌─────────┐  :  ┌─────────┐  ┌────────┐             │
│   │   14    │  :  │   30    │  │   PM   │             │
│   └─────────┘     └─────────┘  └────────┘             │
│                                                         │
│  ┌──────────────────┐      ┌──────────────────┐        │
│  │     Cancel       │      │      Done        │        │
│  └──────────────────┘      └──────────────────┘        │
└─────────────────────────────────────────────────────────┘
```

**Visual Elements:**
- Clock icon (🕐) instead of calendar
- Date and time in formatted text
- Calendar + Time picker wheels
- Same Cancel/Done buttons

---

## 🎨 Color Scheme

### Primary Colors
```
Primary Blue:    #A8D8EA  ████  (Icons, borders, Done button)
Card Background: #FFFFFF  ████  (Picker background)
Text Color:      #4A4A4A  ████  (Date text)
Background:      #FFF9F0  ████  (Page background)
Shadow:          #00000019 ████  (Subtle shadow)
```

### State Colors
```
Default:   White background, no border
Active:    White background, blue border (2px)
Hover:     Slightly larger shadow
```

---

## 📐 Dimensions

### Collapsed State
```
Height:        ~56px
Padding:       16px (all sides)
Icon Size:     20px
Text Size:     17px (body)
Chevron Size:  14px
Corner Radius: 12px
Shadow:        2px blur, 1px offset
```

### Expanded State
```
Picker Height: ~400px (calendar) or ~500px (calendar + time)
Padding:       16px (all sides)
Corner Radius: 16px
Shadow:        8px blur, 4px offset
Button Height: ~44px
Button Spacing: 16px between Cancel and Done
```

---

## 🎬 Animation Sequence

### Expand Animation (0.3s)
```
1. Chevron rotates: ▼ → ▲
2. Border appears: none → blue (2px)
3. Shadow grows: 2px → 8px
4. Picker slides in: scale(0.95) + opacity(0) → scale(1) + opacity(1)
5. Spring effect: dampingFraction 0.7
```

### Collapse Animation (0.3s)
```
1. Chevron rotates: ▲ → ▼
2. Border fades: blue → none
3. Shadow shrinks: 8px → 2px
4. Picker slides out: scale(1) + opacity(1) → scale(0.95) + opacity(0)
5. Spring effect: dampingFraction 0.7
```

---

## 📱 Responsive Behavior

### iPhone (Portrait)
```
┌─────────────────────────┐
│  Full width picker      │
│  Padding: 16px          │
└─────────────────────────┘
```

### iPad (Portrait/Landscape)
```
┌─────────────────────────────────────┐
│  Same design, scales with parent    │
│  Padding: 16px                      │
└─────────────────────────────────────┘
```

---

## 🌍 Localization Examples

### English
```
Collapsed:  📅  December 9, 2025
Expanded:   December 2025
            Sun Mon Tue Wed Thu Fri Sat
DateTime:   🕐  Dec 9, 2025 at 2:30 PM
```

### Vietnamese
```
Collapsed:  📅  9 tháng 12, 2025
Expanded:   Tháng 12 năm 2025
            CN  T2  T3  T4  T5  T6  T7
DateTime:   🕐  9 thg 12, 2025 lúc 14:30
```

---

## 🎯 Usage in Different Contexts

### 1. Visit Date (AddVisitView)
```
Label:      "Visit Date"
Mode:       .date
Range:      None (any date)
Icon:       📅
```

### 2. Date of Birth (AddMemberView)
```
Label:      "Date of Birth"
Mode:       .date
Range:      ...Date() (past only)
Icon:       📅
```

### 3. Reminder Time (ReminderSheet)
```
Label:      "Select Custom Date & Time"
Mode:       .dateAndTime
Range:      Date()... (future only)
Icon:       🕐
```

---

## ✨ Special Features

### 1. Smart Icon Selection
- Date mode: Calendar icon (📅)
- DateTime mode: Clock icon (🕐)

### 2. Contextual Formatting
- Date only: "December 9, 2025"
- Date + Time: "Dec 9, 2025 at 2:30 PM"

### 3. Range Constraints
- Past only: Grays out future dates
- Future only: Grays out past dates
- Custom range: Grays out dates outside range

### 4. Temporary Selection
- Changes stored in `tempDate` state
- Only applied when "Done" is tapped
- Reverted when "Cancel" is tapped

---

**Visual Guide Version:** 1.0  
**Last Updated:** December 9, 2025  
**Author:** Cường Trần


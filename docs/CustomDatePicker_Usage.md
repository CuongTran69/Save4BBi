# CustomDatePicker - Hướng Dẫn Sử Dụng

## 🎯 Cách Chọn Ngày

### Bước 1: Mở DatePicker
Click vào button hiển thị ngày hiện tại:

```
┌─────────────────────────────────────────┐
│  📅  December 9, 2025              ▼   │  ← Click vào đây
└─────────────────────────────────────────┘
```

### Bước 2: Chọn Ngày Trong Calendar
Calendar sẽ mở ra, click vào ngày bạn muốn chọn:

```
┌─────────────────────────────────────────┐
│  📅  December 9, 2025              ▲   │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│              December 2025              │
│                                         │
│   Sun  Mon  Tue  Wed  Thu  Fri  Sat    │
│                              1    2     │
│    3    4    5    6    7    8    9     │
│   10   11   12   13   14   15   16     │  ← Click vào ngày
│   17   18   19   20   21   22   23     │
│   24   25   26   27   28   29   30     │
│   31                                    │
└─────────────────────────────────────────┘
```

### Bước 3: Click "Done" Để Lưu
**QUAN TRỌNG:** Sau khi chọn ngày, bạn PHẢI click nút "Done" để lưu:

```
┌─────────────────────────────────────────┐
│  ┌──────────────────┐  ┌──────────────────┐
│  │     Cancel       │  │      Done        │  ← Click Done
│  └──────────────────┘  └──────────────────┘
└─────────────────────────────────────────┘
```

**Nếu click "Cancel":** Ngày sẽ KHÔNG được lưu, quay về ngày cũ.

---

## ❓ Troubleshooting

### Vấn Đề 1: "Tôi click vào ngày nhưng không thay đổi"

**Nguyên nhân:** Bạn chưa click nút "Done"

**Giải pháp:**
1. Click vào ngày trong calendar
2. **Nhớ click nút "Done" màu xanh**
3. DatePicker sẽ đóng lại và ngày mới được lưu

---

### Vấn Đề 2: "Tôi không thấy calendar"

**Nguyên nhân:** DatePicker chưa được mở

**Giải pháp:**
1. Click vào button hiển thị ngày (có icon 📅)
2. Calendar sẽ xuất hiện bên dưới
3. Nếu vẫn không thấy, scroll xuống

---

### Vấn Đề 3: "Một số ngày bị mờ, không click được"

**Nguyên nhân:** Ngày đó nằm ngoài range cho phép

**Ví dụ:**
- **Date of Birth:** Chỉ cho phép chọn ngày trong quá khứ (không thể chọn ngày mai)
- **Reminder:** Chỉ cho phép chọn ngày trong tương lai (không thể chọn ngày hôm qua)

**Giải pháp:** Chọn ngày khác trong range cho phép

---

### Vấn Đề 4: "DatePicker không mở"

**Kiểm tra:**
1. Có thông báo lỗi trong console không?
2. Thử restart app
3. Kiểm tra xem có conflict với view khác không

**Debug:**
- Mở console trong Xcode
- Tìm log bắt đầu với "📅" hoặc "✅"
- Gửi log cho developer

---

## 🎨 UI States

### State 1: Closed (Đóng)
```
┌─────────────────────────────────────────┐
│  📅  December 9, 2025              ▼   │
└─────────────────────────────────────────┘
```
- Border: Không có
- Chevron: Hướng xuống (▼)
- Calendar: Ẩn

### State 2: Open (Mở)
```
┌─────────────────────────────────────────┐
│  📅  December 9, 2025              ▲   │  ← Border xanh
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│        [Calendar hiển thị]              │
│  ┌──────────┐        ┌──────────┐      │
│  │  Cancel  │        │   Done   │      │
│  └──────────┘        └──────────┘      │
└─────────────────────────────────────────┘
```
- Border: Xanh (2px)
- Chevron: Hướng lên (▲)
- Calendar: Hiển thị
- Buttons: Cancel (xám) và Done (xanh)

---

## 📝 Flow Diagram

```
User clicks button
       ↓
Calendar opens
       ↓
User selects date in calendar
       ↓
tempDate updates (internal state)
       ↓
User clicks "Done"
       ↓
date = tempDate (saved)
       ↓
Calendar closes
       ↓
New date displayed
```

**Nếu user clicks "Cancel":**
```
User clicks "Cancel"
       ↓
tempDate discarded
       ↓
Calendar closes
       ↓
Old date still displayed (không thay đổi)
```

---

## 🔍 Debug Mode

Nếu bạn là developer và muốn debug:

### Console Logs

Khi chọn ngày, bạn sẽ thấy:
```
📅 DatePicker changed: 2025-12-09 00:00:00 +0000 -> 2025-12-15 00:00:00 +0000
```

Khi click Done:
```
✅ Done clicked: tempDate = 2025-12-15 00:00:00 +0000, old date = 2025-12-09 00:00:00 +0000
✅ New date = 2025-12-15 00:00:00 +0000
```

### Test View

Sử dụng `CustomDatePickerTest` view để test:
```swift
CustomDatePickerTest()
```

View này có:
- CustomDatePicker để test
- Standard DatePicker để so sánh
- Debug info hiển thị selected date
- Toggle để show/hide debug info

---

## ✅ Expected Behavior

### Scenario 1: Chọn ngày mới
1. Click button → Calendar mở
2. Click ngày 15 → tempDate = Dec 15
3. Click Done → date = Dec 15, calendar đóng
4. Button hiển thị "December 15, 2025" ✅

### Scenario 2: Cancel
1. Click button → Calendar mở
2. Click ngày 15 → tempDate = Dec 15
3. Click Cancel → tempDate bị discard, calendar đóng
4. Button vẫn hiển thị ngày cũ "December 9, 2025" ✅

### Scenario 3: Chọn nhiều ngày
1. Click button → Calendar mở
2. Click ngày 15 → tempDate = Dec 15
3. Click ngày 20 → tempDate = Dec 20
4. Click ngày 25 → tempDate = Dec 25
5. Click Done → date = Dec 25 (ngày cuối cùng được chọn) ✅

---

## 💡 Tips

1. **Luôn nhớ click Done:** Đây là bước quan trọng nhất!
2. **Cancel để hủy:** Nếu chọn nhầm, click Cancel
3. **Scroll nếu cần:** Calendar có thể dài, scroll để xem tháng khác
4. **Check range:** Một số ngày có thể bị disable do range constraint

---

**Last Updated:** December 9, 2025  
**Version:** 1.0  
**Author:** Cường Trần


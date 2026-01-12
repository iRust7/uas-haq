# Book Library - Complete Project Roadmap

**Project**: Offline Book Library & PDF Reader (PDF-first)

**Created**: 11 Januari 2026

**Goal**: UAS Flutter project dengan fitur lengkap reading app offline

---

## 📊 Overall Progress

```
ALPHA v0: ████████████████████ 100% ✅ COMPLETED
ALPHA v1: ████████████████████ 100% ✅ COMPLETED
ALPHA v2: ████████████████████ 100% ✅ COMPLETED
ALPHA v3: ████████████████████ 100% ✅ COMPLETED
ALPHA v4: ░░░░░░░░░░░░░░░░░░░░   0% 🚧 IN PROGRESS
ALPHA v5: ░░░░░░░░░░░░░░░░░░░░   0% ⏳ PLANNED
BETA:     ░░░░░░░░░░░░░░░░░░░░   0% ⏳ PLANNED
```

**Total Project**: ~57% Complete

---

## 🎯 Rubrik UAS Coverage Status

| Kriteria | Bobot | Status | Phase | Notes |
|----------|-------|--------|-------|-------|
| Materi sebelum UTS | 10% | ✅ | v0 | Widget, Layout, Navigator |
| ListView/GridView | 5% | ✅ | v0 | ListView.builder + Card |
| Membawa Data | 10% | ✅ | v1 | MaterialPageRoute, Book object |
| CRUD Lokal/API | 10% | ✅ | v2 | Full Book CRUD with Hive |
| Login Lokal/API | 5% | ✅ | v0 | Guest mode + Registration |
| Tampilan | 10% | ✅ | v0-v3 | Card, FAB, Dialog, Chips |
| Fitur Inovatif | 20% | 🚧 | v0,v3,v5 | Guest mode ✅, PDF import ✅, Share next |
| **TOTAL** | **70%** | **~60%** | | |

**Target**: Minimal 60% untuk nilai baik

**Current**: ~60% done, ~40% to go (target achieved! 🎉)

---

## 📅 Phase Breakdown

### ✅ ALPHA v0 - Foundation & Optional Login
**Duration**: 11 Jan 2026  
**Status**: COMPLETED ✅

**Achievements**:
- ✅ Flutter project setup (feature-based structure)
- ✅ Hive integration (2 boxes: 'user', 'users')
- ✅ User model dengan password & isGuest
- ✅ SessionRepository dengan multi-user support
- ✅ Guest mode (auto-login, no forced login)
- ✅ User registration dengan validation
- ✅ Login screen dengan password check
- ✅ LibraryScreen dengan ListView.builder + dummy data
- ✅ AppTheme, validators, routes

**Documentation**: [alpha-v0.md](alpha-v0.md)

**Rubrik Covered**:
- ✅ Materi sebelum UTS (10%)
- ✅ ListView/GridView (5%)
- ✅ Login Lokal (5%)
- ✅ Tampilan (partial: Card, FAB, Dialog)
- ✅ Fitur Inovatif (partial: Guest mode)

---

### ✅ ALPHA v1 - BookDetailScreen + Data Passing
**Duration**: 11 Jan 2026  
**Status**: COMPLETED ✅

**Achievements**:
- ✅ BookDetailScreen dengan 4 sections:
  - Header (icon, title, author, tags, date)
  - Progress (circular + linear, completion badge)
  - Bookmarks (grid chips, empty state)
  - Actions (Continue Reading, Edit, Share, Delete)
- ✅ Data passing: LibraryScreen → BookDetailScreen
- ✅ MaterialPageRoute dengan Book object
- ✅ Placeholder actions untuk future phases
- ✅ intl dependency untuk DateFormat

**Documentation**: [alpha-v1.md](alpha-v1.md)

**Rubrik Covered**:
- ✅ Membawa Data (10%)
- ✅ Tampilan (enhanced: CircularProgress, Chips, Wrap)

---

### ✅ ALPHA v2 - CRUD Book dengan Hive
**Duration**: 11 Jan 2026  
**Status**: COMPLETED ✅

**Achievements**:
- ✅ Book Hive Model dengan HiveType annotations
- ✅ BookRepository full CRUD operations
- ✅ BookFormScreen (Add/Edit dalam 1 screen)
- ✅ Delete with file cleanup
- ✅ Library refresh after CRUD
- ✅ FAB functional
- ✅ Form validation

**Documentation**: [alpha-v2.md](alpha-v2.md)

**Rubrik Covered**:
- ✅ CRUD Lokal/API (10%)

---

### ✅ ALPHA v3 - Import PDF via File Picker
**Duration**: 11 Jan 2026  
**Status**: COMPLETED ✅

**Achievements**:
- ✅ file_picker & path_provider integration
- ✅ PDF-only file filter
- ✅ Copy to app storage (/books/ directory)
- ✅ Auto-fill title from filename
- ✅ Visual state feedback (blue → green)
- ✅ Error handling
- ✅ Remove selection option

**Documentation**: [alpha-v3.md](alpha-v3.md)

**Rubrik Covered**:
- ✅ Fitur Inovatif (partial: Import PDF)

---

### 🚧 ALPHA v4 - PDF Reader + Progress Tracking
**Target Duration**: 2-3 hours  
**Status**: IN PROGRESS 🚧

**Planned Features**:
1. **Book Hive Model**
   - Add HiveType annotations ke Book model
   - Generate Hive adapter untuk Book (typeId: 1)
   - Open Hive box 'books'

2. **BookRepository CRUD**
   - `createBook()` - Add new book to Hive
   - `getAllBooks()` - Get all books dari Hive (replace dummy)
   - `updateBook()` - Update book metadata
   - `deleteBook()` - Delete book dari Hive
   - Optional: `getBookById()`

3. **BookFormScreen**
   - Add/Edit mode (1 screen, 2 modes)
   - Form fields: title, author, tags (comma-separated)
   - Validation
   - Save to Hive

4. **Integration**
   - LibraryScreen FAB → BookFormScreen (add mode)
   - BookDetailScreen Edit → BookFormScreen (edit mode)
   - BookDetailScreen Delete → Actual deletion + pop
   - Refresh Library after CRUD

**Documentation**: [alpha-v2.md](alpha-v2.md) (to be created)

**Rubrik Target**:
- ✅ CRUD Lokal/API (10%) - Book CRUD completion

**Estimated Effort**: 1-2 hours

---

### ⏳ ALPHA v3 - Import PDF via File Picker
**Target Duration**: 1-2 hours  
**Status**: PLANNED ⏳

**Planned Features**:
1. **Dependencies**
   - Add `file_picker` package
   - Add `path_provider` untuk app directory

2. **File Picker Integration**
   - Pick PDF file from device storage
   - Copy PDF to app directory (permanent storage)
   - Extract metadata: filename → title, file size

3. **BookFormScreen Enhancement**
   - "Import PDF" button
   - Auto-fill title from filename
   - Show file path/name after import
   - Save filePath di Book model

4. **Validation**
   - Only accept .pdf files
   - File size limit (optional)
   - Error handling untuk failed imports

**Documentation**: To be created

**Rubrik Target**:
- ✅ Fitur Inovatif (partial: PDF import)

**Estimated Effort**: 1-2 hours

---

### ⏳ ALPHA v4 - PDF Reader + Progress Tracking
**Target Duration**: 2-3 hours  
**Status**: PLANNED ⏳

**Planned Features**:
1. **PDF Viewer Plugin**
   - Research: `syncfusion_flutter_pdfviewer` vs `flutter_pdfview`
   - Recommendation: `syncfusion_flutter_pdfviewer` (easier, free tier)

2. **ReaderScreen**
   - Display PDF from file path
   - Page navigation (swipe, tap)
   - Current page indicator
   - Save lastPage on page change (debounced)

3. **Progress Persistence**
   - Update Book.lastPage di Hive
   - Update Book.totalPages on first open
   - BookDetailScreen "Continue Reading" → Navigate to ReaderScreen
   - Restore to lastPage when opening

4. **Basic Controls**
   - Zoom in/out (if supported by plugin)
   - Page jump (optional)

**Documentation**: To be created

**Rubrik Target**:
- Enhanced user experience
- Real functionality untuk Continue Reading

**Estimated Effort**: 2-3 hours

---

### ⏳ ALPHA v5 - Bookmarks + Share Feature
**Target Duration**: 1-2 hours  
**Status**: PLANNED ⏳

**Planned Features**:
1. **Bookmarks CRUD**
   - Add bookmark button di ReaderScreen
   - Remove bookmark (if already bookmarked)
   - Update Book.bookmarks list di Hive
   - BookDetailScreen bookmarks → Tap to open ReaderScreen at that page

2. **Share Feature**
   - `url_launcher` dependency
   - Share button functional di BookDetailScreen
   - **WhatsApp Share**:
     - Text: "Sedang baca: {title} oleh {author} - Progress {X}% (Hal {lastPage}/{totalPages})"
     - `whatsapp://send?text=...`
   - **Email Share**:
     - Subject: "Book Recommendation: {title}"
     - Body: Same as WhatsApp text
     - `mailto:?subject=...&body=...`

3. **UI Enhancement**
   - Share dialog: pilih WhatsApp atau Email
   - Error handling jika app tidak tersedia

**Documentation**: To be created

**Rubrik Target**:
- ✅ Fitur Inovatif (completion: PDF import + Share)

**Estimated Effort**: 1-2 hours

---

### ⏳ BETA - UI Polish & GridView Toggle
**Target Duration**: 1-2 hours  
**Status**: PLANNED ⏳

**Planned Features**:
1. **GridView Toggle**
   - Toggle button di LibraryScreen AppBar
   - GridView.builder untuk grid layout
   - Persistent preference (SharedPreferences or Hive)
   - Both modes use same BookCard (responsive)

2. **Responsive Layout**
   - Test di berbagai screen sizes
   - Adjust spacing, padding
   - Ensure readable text

3. **Animations**
   - Page transitions (optional)
   - Fade-in untuk images (optional)
   - Smooth toggle animation

4. **UI Refinements**
   - Consistent spacing
   - Better color harmony
   - Icon improvements
   - Empty states polish

**Documentation**: To be created

**Rubrik Target**:
- ✅ ListView/GridView (completion: both modes)
- Enhanced Tampilan

**Estimated Effort**: 1-2 hours

---

## 🚀 Production Release

### Testing & Quality
- [ ] Unit tests untuk repositories
- [ ] Widget tests untuk key screens
- [ ] Integration tests untuk main flows
- [ ] Manual testing checklist completion
- [ ] Bug fixes

### Documentation
- [ ] README.md lengkap dengan:
  - Screenshots semua screens
  - Features list
  - Installation instructions
  - Usage guide
  - Tech stack
- [ ] CHANGELOG.md
- [ ] Code comments cleanup

### Build & Deployment
- [ ] Build APK release: `flutter build apk --release`
- [ ] Test APK di real device
- [ ] Create GitHub release dengan APK attachment

### Presentation Materials
- [ ] Video demo (3-5 minutes)
- [ ] PowerPoint/slides untuk presentasi
- [ ] Highlight rubrik coverage
- [ ] Show code quality & structure

**Estimated Effort**: 2-3 hours

---

## 📊 Timeline Estimate

| Phase | Duration | Cumulative |
|-------|----------|------------|
| ALPHA v0 | 3 hours | 3h |
| ALPHA v1 | 1 hour | 4h |
| ALPHA v2 | 1-2 hours | 5-6h |
| ALPHA v3 | 1-2 hours | 6-8h |
| ALPHA v4 | 2-3 hours | 8-11h |
| ALPHA v5 | 1-2 hours | 9-13h |
| BETA | 1-2 hours | 10-15h |
| Production | 2-3 hours | 12-18h |

**Total Estimated**: 12-18 hours of focused development

**Already Spent**: ~4 hours

**Remaining**: ~8-14 hours

---

## 🎓 Final Rubrik Projection

After all phases complete:

| Kriteria | Target Score | Expected |
|----------|--------------|----------|
| Materi sebelum UTS | 10% | ✅ 10% |
| ListView/GridView | 5% | ✅ 5% |
| Membawa Data | 10% | ✅ 10% |
| CRUD Lokal/API | 10% | ✅ 10% |
| Login Lokal/API | 5% | ✅ 5% |
| Tampilan | 10% | ✅ 10% |
| Fitur Inovatif | 20% | ✅ 18-20% |
| **TOTAL** | **70%** | **68-70%** |

**Projected Final Score**: **~68-70%** (A/A- range)

---

## 💡 Risk Mitigation

### High Priority (Must Have)
- ✅ v0: Foundation ✅
- ✅ v1: Data passing ✅
- 🚧 v2: CRUD Book
- ⏳ v3: PDF Import
- ⏳ v4: PDF Reader

**If time is limited**: Stop after v4. You'll have ~60-65% rubrik coverage.

### Medium Priority (Should Have)
- ⏳ v5: Share feature
- ⏳ BETA: GridView toggle

**Nice boost**: Additional ~5-8% rubrik coverage.

### Low Priority (Nice to Have)
- BETA: Animations
- Extensive testing
- Perfect documentation

**Focus on functionality** over perfection.

---

## 📱 Feature Matrix

| Feature | v0 | v1 | v2 | v3 | v4 | v5 | BETA |
|---------|----|----|----|----|----|----|------|
| Guest Mode | ✅ | | | | | | |
| Registration | ✅ | | | | | | |
| Login/Logout | ✅ | | | | | | |
| List Books | ✅ | | | | | | |
| View Detail | | ✅ | | | | | |
| Add Book | | | ✅ | | | | |
| Edit Book | | | ✅ | | | | |
| Delete Book | | | ✅ | | | | |
| Import PDF | | | | ✅ | | | |
| Read PDF | | | | | ✅ | | |
| Track Progress | | | | | ✅ | | |
| Bookmarks | | | | | | ✅ | |
| Share | | | | | | ✅ | |
| Grid View | | | | | | | ✅ |

---

## 🎯 Success Metrics

### Minimum Viable Product (MVP)
- [x] User can browse books
- [x] User can view book details
- [ ] User can add books
- [ ] User can import PDF
- [ ] User can read PDF
- [ ] Reading progress saved

**Status**: 33% complete (2/6)

### Full Feature Set
All MVP + Share + Bookmarks + GridView

**Status**: 20% complete (2/10)

### Production Ready
Full Feature + Tests + Documentation + APK

**Status**: 15% complete (phase completion)

---

## 📝 Notes

1. **Flexibility**: Roadmap bisa disesuaikan berdasarkan feedback dan keterbatasan waktu
2. **Documentation**: Setiap fase didokumentasikan di `docs/alpha-vX.md`
3. **Git Commits**: Commit after each phase completion
4. **Testing**: Manual testing after each phase, automated tests di Production
5. **Code Quality**: Maintain clean code, comments, dan structure sepanjang development

---

## 🔗 Quick Links

- [Main Documentation](README.md)
- [ALPHA v0 Docs](alpha-v0.md) ✅
- [ALPHA v1 Docs](alpha-v1.md) ✅
- [ALPHA v2 Docs](alpha-v2.md) 🚧
- [Task Tracking](../brain/.../task.md)

---

**Last Updated**: 11 Januari 2026

**Next Phase**: [ALPHA v2 - CRUD Book](alpha-v2.md)

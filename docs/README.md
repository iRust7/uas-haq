# Book Library - Documentation Index

**Project**: Offline Book Library & PDF Reader (PDF-first)

**Created**: 11 Januari 2026

---

## 📚 Phase Documentation

### Completed Phases
- [ALPHA v0 - Foundation & Optional Login](alpha-v0.md) ✅
- [ALPHA v1 - BookDetailScreen + Data Passing](alpha-v1.md) ✅
- [ALPHA v2 - CRUD Book dengan Hive](alpha-v2.md) ✅
- [ALPHA v3 - Import PDF via File Picker](alpha-v3.md) ✅

### Current Phase
- ALPHA v4 - ReaderScreen + Progress Tracking 🚧

### Planned Phases
- ALPHA v5 - Bookmarks + Share Feature ⏳
- BETA - UI Polish & GridView Toggle ⏳

---

## 🎯 Overall Progress

| Phase | Feature | Status | Rubrik Coverage |
|-------|---------|--------|-----------------|
| v0 | Project Setup | ✅ | Widget, Layout, Navigator |
| v0 | Hive Storage | ✅ | Local Storage |
| v0 | Guest Mode | ✅ | Session, Innovative |
| v0 | Registration | ✅ | CRUD (User), Form Validation |
| v0 | Library List | ✅ | ListView.builder, Card |
| v1 | Book Detail | ✅ | **Data Passing** |
| v2 | Book CRUD | ✅ | **CRUD (Book)**, Dialog |
| v3 | Import PDF | ✅ | File Picker, **Innovative** |
| v4 | PDF Reader | 🚧 | Plugin Integration |
| v5 | Share | ⏳ | url_launcher, Innovative |
| Beta | UI Polish | ⏳ | GridView, Responsive |

**Legend**:
- ✅ Completed
- 🚧 In Progress
- ⏳ Planned

---

## 🏗️ Project Structure

```
uas-haq/
├── lib/                    # Source code
│   ├── main.dart
│   ├── app.dart
│   ├── core/              # Theme, utils, constants
│   ├── data/              # Models, repositories
│   ├── features/          # UI screens (feature-based)
│   └── routes/            # App routes
├── docs/                  # Phase documentation
│   ├── README.md          # This file
│   ├── alpha-v0.md
│   ├── alpha-v1.md
│   └── ...
├── prompt-ai/             # AI Agent prompts & specs
│   ├── prompt agent.md
│   ├── instruction.md
│   ├── project overview.md
│   └── architecture.md
└── test/                  # Unit tests
```

---

## 🛠️ Tech Stack

### Core
- **Flutter**: Framework
- **Dart**: Language

### Storage
- **Hive**: NoSQL local database
- **hive_flutter**: Flutter integration
- **hive_generator**: Code generation
- **build_runner**: Build tools

### Utilities
- **uuid**: Generate unique IDs

### Future (ALPHA v3+)
- **file_picker**: Import PDF files
- **syncfusion_flutter_pdfviewer** / **flutter_pdfview**: PDF rendering
- **url_launcher**: Share to WhatsApp/Email

---

## 📋 Rubrik UAS Coverage

| Kriteria (Bobot) | Status | Implementation | Phase |
|-------------------|--------|----------------|-------|
| Materi sebelum UTS (10%) | ✅ | Widget, Layout, Navigator | v0 |
| ListView/GridView (5%) | ✅ | ListView.builder + Card | v0 |
| Membawa Data (10%) | ✅ | Constructor data passing | v1 |
| CRUD Lokal/API (10%) | ✅ | Hive Book CRUD | v2 |
| Login Lokal/API (5%) | ✅ | Guest + Registration | v0 |
| Tampilan (10%) | ✅ | Card, FAB, Dialog | v0-v3 |
| Fitur Inovatif (20%) | 🚧 | Guest mode ✅, Import PDF ✅, Share ⏳ | v0, v3, v5 |

**Total Coverage**: ~65% ✅ | ~35% 🚧⏳

---

## 🚀 Quick Start

```bash
# Clone & setup
cd e:\uass\uas-haq
flutter pub get

# Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Run tests
flutter test

# Build APK
flutter build apk --release
```

---

## 📞 Contact & Resources

**Developer**: [Your Name]

**Repository**: [GitHub URL]

**Documentation**: `docs/` folder

**AI Agent Specs**: `prompt-ai/` folder

---

## 📝 Changelog

### 2026-01-11
- ✅ ALPHA v0 Completed
  - Project setup
  - Hive integration
  - Guest mode & registration
  - Library screen dengan dummy data
- ✅ ALPHA v1 Completed
  - BookDetailScreen dengan data passing
  - Progress display & bookmarks
- ✅ ALPHA v2 Completed
  - Full Book CRUD with Hive
  - BookFormScreen (Add/Edit)
  - Delete with confirmation dialog
- ✅ ALPHA v3 Completed
  - Import PDF via file_picker
  - Copy to app storage
  - Auto-fill title from filename
- 🚧 ALPHA v4 In Progress
  - PDF Reader implementation next

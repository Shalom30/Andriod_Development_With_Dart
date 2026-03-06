# 🎓 Grade Vault

A stunning Flutter desktop application for processing and reporting student grades.

---

## Features

- 📂 Import student data from Excel (.xlsx) files
- 📊 Automatically calculates final marks, grades, and GPA
- 📋 View all results in a sortable, searchable table
- 📥 Export results as a formatted Excel file
- 🖨️ Export results as a styled PDF report
- 🌙 Beautiful dark-themed UI

---

## Grading Scale

| Grade | GPA | Mark Range |
|-------|-----|-----------|
| A     | 4.0 | 80 – 100  |
| B+    | 3.5 | 70 – 79   |
| B     | 3.0 | 60 – 69   |
| C+    | 2.5 | 55 – 59   |
| C     | 2.0 | 50 – 54   |
| D+    | 1.5 | 45 – 49   |
| D     | 1.0 | 40 – 44   |
| F     | 0.0 | 0 – 39    |

---

## Mark Calculation

- **CA Component**: The CA mark is out of 40 → contributes 40 points
- **Exam Component**: The exam mark is out of 100 → converted to out of 60  
  `exam_component = (exam_mark / 100) × 60`
- **Final Mark**: `CA Component + Exam Component` (out of 100)

---

## Excel File Format

Your input `.xlsx` file must have:

| Column A       | Column B      | Column C        |
|----------------|---------------|-----------------|
| Student Name   | CA Mark (/40) | Exam Mark (/100)|
| Alice Johnson  | 35            | 78              |
| Bob Smith      | 28            | 55              |

Row 1 is a header row (any text is fine). Data starts from Row 2.

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x or later
- Dart SDK 3.x or later
- Windows / Linux / macOS desktop

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/grade_vault.git
cd grade_vault

# 2. Install dependencies
flutter pub get

# 3. Enable desktop support (first time only)
flutter config --enable-windows-desktop   # Windows
flutter config --enable-linux-desktop     # Linux
flutter config --enable-macos-desktop     # macOS

# 4. Run the app
flutter run -d windows   # or linux / macos
```

---

## OOP Concepts Used

| Concept | Where |
|---------|-------|
| **OOP (classes & encapsulation)** | `Student`, `ExcelService`, `PdfService`, `HomeScreen`, `ResultsScreen` |
| **Inheritance** | `GradeCalculator extends Calculator` — *a GradeCalculator IS-A Calculator* |
| **Lambdas** | `.map()`, `.where()`, `.reduce()`, `firstWhere()`, sort comparators |
| **Functions** | `readStudents()`, `writeResults()`, `generatePdf()`, `_pickFile()` |
| **Delayed init (late)** | `finalMark`, `grade`, `gpa` in `Student`; stats in `ResultsScreen` |
| **GUI (Flutter)** | Full desktop application with routing, theming, animations |
| **Safe code** | Null safety, try/catch everywhere, input validation |

---

## Project Structure

```
grade_vault/
├── lib/
│   ├── main.dart               # App entry point
│   ├── models/
│   │   └── student.dart        # Student, Calculator, GradeCalculator
│   ├── services/
│   │   ├── excel_service.dart  # Read/write Excel
│   │   └── pdf_service.dart    # Generate PDF reports
│   ├── screens/
│   │   ├── home_screen.dart    # Upload screen
│   │   └── results_screen.dart # Results & export screen
│   ├── widgets/
│   │   ├── grade_badge.dart    # Reusable grade label widget
│   │   └── stat_card.dart      # Summary stat card
│   └── theme/
│       └── app_theme.dart      # All colours, fonts, theming
├── pubspec.yaml                # Dependencies
└── README.md
```

---

## License

MIT — feel free to use and modify.
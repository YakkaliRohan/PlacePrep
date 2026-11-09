# PlacePrep.in — Version 2.0 (Python & Dart / Flutter)

🎯 **Ace Every Campus Placement Interview**  
An enterprise-grade, high-performance interview preparation platform built with **Python (FastAPI)** on the backend and **Dart / Flutter** on the frontend.

---

## 🏗️ Architecture

```
PlacePrep/
├── backend/                   # Python (FastAPI + SQLAlchemy + SQLite/PostgreSQL)
│   ├── app/
│   │   ├── main.py            # FastAPI entry point & CORS configuration
│   │   ├── config.py          # Database URI & JWT auth settings
│   │   ├── database.py        # SQLAlchemy engine & session manager
│   │   ├── models/            # Tables: User, Question, TestAttempt, Feedback
│   │   ├── schemas/           # Pydantic validation schemas
│   │   ├── routers/           # auth, questions, tests, leaderboard, admin
│   │   └── services/          # Authentication & scoring engine
│   ├── seed.py                # Populates 571 questions and default admin
│   ├── requirements.txt       # Python dependencies
│   └── run.sh                 # Fast launch script (port 8000)
│
├── frontend/                  # Dart / Flutter Web & Mobile
│   ├── lib/
│   │   ├── core/theme.dart    # Exact dark theme (#060612, #5227FF, Outfit + Fira Code)
│   │   ├── models/            # Dart data models
│   │   ├── services/          # HTTP REST API client
│   │   ├── providers/         # Auth & Exam state management (Provider)
│   │   └── views/             # Landing, Dashboard, Practice, Exam, Results, Leaderboard, Admin
│   └── pubspec.yaml
│
└── questions_seed.json        # 571 extracted placement questions
```

---

## 🚀 Quick Start Guide

### 1. Launch the Python Backend
```bash
cd backend
source venv/bin/activate
./run.sh
```
* **API Server:** `http://127.0.0.1:8000`
* **Interactive Swagger Docs:** `http://127.0.0.1:8000/api/docs`
* **Default Admin Account:** `admin@placeprep.in` / `PlacePrep2026!`

### 2. Launch the Flutter Web Frontend
```bash
cd frontend
flutter run -d chrome
```
Or view the release build in `frontend/build/web/`.

---

## 🔑 Key Features
1. **571 Curated Placement Questions:** Across Aptitude (200), Logical (116), Verbal (110), Coding (80), and Data Interpretation (65).
2. **10 Company-Specific Tests:** Calibrated to TCS, Infosys, Wipro, Cognizant, Accenture, Amazon, Google, Microsoft, Deloitte, and Goldman Sachs.
3. **Dynamic Exam Engine:** Real-time countdown timer, question palette with answer/flag status tracking, and submit validation.
4. **Detailed Post-Exam Analytics:** Accuracy calculations, section breakdown, and concept-by-concept explanations.
5. **Campus Leaderboard:** Live ranking by questions solved, streaks, and total accuracy.
6. **Admin Panel:** Complete overview of registered students, question banks, and platform metrics.

# 🍽️ Nourishly

**Eat well. Live well.**

Nourishly is a SwiftUI recipe discovery and cooking companion app that helps users explore thousands of recipes, cook with step-by-step guidance, and track their culinary journey.

---

## 📱 Features

### 🔐 Authentication
- **Firebase Authentication** - Email/Password login and registration
- **Guest Mode** - Browse recipes without creating an account
- **Forgot Password** - Reset password via email
- **Session Persistence** - Stay logged in across app launches

### 🍳 Recipe Discovery
- **Browse Categories** - Explore recipes by category (Breakfast, Lunch, Dinner, Beef, Chicken, etc.)
- **Search** - Find recipes by name with instant results
- **Surprise Me!** - Get a random recipe suggestion
- **Full Recipe Details** - View ingredients, instructions, and YouTube tutorials

### 👨‍🍳 Cooking Mode
- **Step-by-Step Guidance** - Follow instructions one step at a time
- **Smart Timer Detection** - Automatically detects and starts timers from instructions
- **Timer Alerts** - Sound and vibration when timer finishes
- **Progress Tracking** - See your cooking progress

### ❤️ Favorites
- **Save Favorites** - Save recipes you love
- **Cloud Sync** - Favorites sync across devices using Firestore
- **Guest Mode Alert** - Prompts guests to sign in to save favorites

### 📚 Cookbook
- **Track Cooked Recipes** - Automatically saves completed recipes
- **Rate Recipes** - Rate recipes from 1-5 stars
- **Add Notes** - Add personal notes and tips
- **Edit Reviews** - Update ratings and notes anytime
- **Cloud Sync** - Cookbook syncs across devices

### 👤 Profile
- **User Stats** - View recipes cooked, favorites, and days active
- **Settings** - Dark mode toggle, logout
- **Guest Mode** - Prompts guests to sign in

---

## 🛠️ Technologies

| Technology | Purpose |
|------------|---------|
| **SwiftUI** | UI framework |
| **Firebase Authentication** | User authentication |
| **Firebase Firestore** | Cloud data sync |
| **TheMealDB API** | Recipe data |
| **AVFoundation** | Timer sounds |
| **UserDefaults** | Local storage |

---

## 🚀 SwiftUI Features Implemented

| # | Feature |
|---|---------|
| 1 | NavigationStack |
| 2 | Searchable |
| 3 | TabView |
| 4 | Pull to Refresh |
| 5 | Context Menu |
| 6 | Sheet Presentation |
| 7 | Alert |
| 8 | ProgressView |
| 9 | AsyncImage |
| 10 | LazyVGrid |
| 11 | Toolbar |
| 12 | @AppStorage |
| 13 | EnvironmentObject |
| 14 | Animation |
| 15 | Timer |

---

## 📁 Project Structure

```
Nourishly/
├── App/
│   └── NourishlyApp.swift
├── Models/
│   ├── Category.swift
│   ├── Cookbook.swift
│   └── Meal.swift
├── Services/
│   ├── AuthService.swift
│   ├── FirebaseManager.swift
│   ├── FirestoreService.swift
│   └── MealService.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   └── MealViewModel.swift
├── Views/
│   ├── Authentication/
│   │   ├── AuthChoiceView.swift
│   │   ├── LoginView.swift
│   │   └── RegisterView.swift
│   ├── Components/
│   │   ├── CategoryCardView.swift
│   │   ├── ErrorView.swift
│   │   ├── LoadingView.swift
│   │   └── MealCardView.swift
│   ├── Cookbook/
│   │   ├── AddRatingView.swift
│   │   ├── CookbookDetailView.swift
│   │   └── CookbookView.swift
│   ├── CookMode/
│   │   └── CookModeView.swift
│   ├── Discover/
│   │   ├── CategoryFoodView.swift
│   │   ├── DiscoverView.swift
│   │   └── FoodDetailView.swift
│   ├── Favorites/
│   │   └── FavoritesView.swift
│   ├── Main/
│   │   └── MainTabView.swift
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   ├── Profile/
│   │   └── ProfileView.swift
│   └── ContentView.swift
├── Extensions/
│   └── Color+Extensions.swift
├── Resources/
│   └── GoogleService-Info.plist
└── Assets.xcassets
```

---

## 🎯 App Flow

```
Launch → Onboarding → Auth Choice
                           ↓
              ┌────────────┼────────────┐
              ↓            ↓            ↓
          Sign In     Create Account   Guest Mode
              ↓            ↓            ↓
              └────────────┼────────────┘
                           ↓
                   Main Tab View
              ┌────────────┼────────────┐
              ↓            ↓            ↓
          Discover    Favorites    Cookbook
          (Browse)    (Saved)      (History)
              ↓            ↓            ↓
          Recipe      Recipe      Rate & Note
          Detail      Detail
              ↓
          Cook Mode
          (Step-by-Step)
```

---

## 🏗️ Installation

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- Swift Package Manager

### Steps
1. Clone the repository:
```bash
git clone https://github.com/snaimio/iOSApp6.git
```

2. Open the project:
```bash
cd iOSApp6
open Nourishly.xcodeproj
```

3. Add `GoogleService-Info.plist` from Firebase Console
4. Build and run:
```
⌘ + R
```

---

## 🔧 Configuration

### Firebase Setup
1. Create a Firebase project
2. Enable Email/Password authentication
3. Enable Firestore
4. Download `GoogleService-Info.plist`
5. Add to project

### API Key
- TheMealDB API is free and uses the test key "1"
- No additional configuration needed

---

## 📄 License

MIT License

Copyright (c) 2026 Sheikh Naim

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

## 👨‍💻 Author

**Sheikh Naim**
- GitHub: [snaimio](https://github.com/snaimio)

---

## 🙏 Acknowledgements

- [TheMealDB](https://www.themealdb.com) for the free recipe API
- [Firebase](https://firebase.google.com) for authentication and cloud storage
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) for the amazing UI framework

---

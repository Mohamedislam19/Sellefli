# Sellefli 🤝

**Sellefli** is a modern peer-to-peer rental marketplace mobile application built with Flutter. It connects people who need items temporarily with those who have them, fostering a circular economy and community sharing. Whether you need a power drill for a weekend project or want to rent out your camping gear, Sellefli makes it easy, secure, and social.

---

## 🚀 Features

*   **User Authentication**: Secure login and signup using Supabase Auth (Phone/Password).
*   **Marketplace Feed**: Browse items by category, search by keywords, and filter by location radius.
*   **Item Management**: Easily list items with photos, descriptions, prices, and availability dates.
*   **Booking System**: Request items, manage booking status (pending, accepted, completed), and track returns.
*   **Geolocation**: Find items near you using interactive maps and location services.
*   **Rating & Reviews**: Build trust within the community through a robust rating system for both lenders and borrowers.
*   **Profile Management**: Manage your public profile, listings, and rental history.

---

## 🛠️ Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/) (Dart)
*   **Backend & Database**: [Supabase](https://supabase.com/) (PostgreSQL)
*   **State Management**: **flutter_bloc (Cubit)**
*   **Navigation**: Flutter Named Routes
*   **Maps**: `flutter_map` & `latlong2`
*   **Styling**: Custom Theme & Google Fonts (`Outfit`)

---

## 📂 Project Structure

The project follows a **Feature-First Clean Architecture** to ensure scalability and maintainability.

```
lib/
├── main.dart                 # Application entry point
├── app.dart                  # App configuration (Theme, Routes)
└── src/
    ├── core/                 # Shared resources across the app
    │   ├── theme/            # App colors, text styles, theme data
    │   └── widgets/          # Reusable UI components (Buttons, Inputs, etc.)
    ├── data/                 # Data layer
    │   └── models/           # Dart data models (User, Item, Booking, etc.)
    └── features/             # Feature-based modules
        ├── auth/             # Authentication logic & UI
        ├── home/             # Marketplace feed & search
        ├── item/             # Item creation & details
        ├── booking/          # Booking management
        ├── profile/          # User profile & settings
        └── ...
```

---

## 🧠 State Management

We use the **BLoC pattern (Business Logic Component)**, specifically **Cubits**, to manage state. This separates business logic from the UI, making the code testable and reusable.

*   **Cubits**: Handle state changes (e.g., `AuthCubit`, `HomeCubit`, `BookingCubit`).
*   **States**: Immutable classes representing the UI state (e.g., `AuthLoading`, `AuthAuthenticated`, `AuthError`).
*   **Repositories**: Handle data fetching from Supabase and are injected into Cubits.

---

## ⚡ Getting Started

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest Stable)
*   [Git](https://git-scm.com/)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Mohamedislam19/Sellefli.git
    cd Sellefli
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```

### Supabase Setup

This project uses Supabase for the backend. Ensure you have the correct credentials in `lib/main.dart`:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

*Refer to `SUPABASE_SETUP_GUIDE.md` for detailed backend setup instructions.*

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/amazing-feature`).
3.  Commit your changes (`git commit -m 'Add some amazing feature'`).
4.  Push to the branch (`git push origin feature/amazing-feature`).
5.  Open a Pull Request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

# Kigali City Services

A Flutter mobile application that allows residents and visitors of Kigali, Rwanda, to discover, add, and navigate local services including restaurants, hospitals, cafés, and other points of interest.

---

## Features

| Feature | Description |
|---|---|
| Authentication | Email/password signup & login via Firebase Auth with mandatory email verification |
| Directory | Browse all listings with real-time Firestore updates |
| My Listings | View, edit, and delete listings created by the signed-in user |
| Map View | Embedded Google Map displaying markers for all listings |
| Search & Filter | Search by name and filter by category (client-side, instant) |
| Listing Detail | Full detail page with embedded map marker and navigation launch |
| Settings | Display user profile and toggle notification preference |

---

## Tech Stack

- **Framework:** Flutter (Dart)
- **Backend:** Firebase (Auth + Firestore)
- **Maps:** google_maps_flutter + url_launcher (for navigation)
- **State Management:** Provider (ChangeNotifier)
- **Min SDK:** Android 21 (Lollipop)

---

## Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Email/Password** authentication under Authentication → Sign-in method.
3. Create a **Cloud Firestore** database in production mode.
4. Register an Android app and download `google-services.json` → place in `android/app/`.
5. Enable **Maps SDK for Android** in Google Cloud Console → APIs & Services.
6. Add your Maps API key to `android/app/src/main/AndroidManifest.xml`:

```xml
<application ...>
  <meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
  ...
</application>
```

7. Deploy Firestore Security Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.ownerId;
    }
  }
}
```

---

## Firestore Database Structure

### `users/{uid}`
```
{
  uid:                   String   // Firebase Auth UID
  displayName:           String
  email:                 String
  createdAt:             Timestamp
  notificationsEnabled:  Boolean
}
```

### `listings/{listingId}`
```
{
  id:          String    // Firestore document ID
  ownerId:     String    // Auth UID of creator
  name:        String
  category:    String    // Restaurant | Hospital | Café | Hotel | Other
  address:     String
  contact:     String
  description: String
  latitude:    Double
  longitude:   Double
  createdAt:   Timestamp
}
```

---

## State Management

The app uses **Provider** with two ChangeNotifier classes:

### `AuthProvider`
- Wraps `FirebaseAuth.instance.authStateChanges()`
- Polls `user.emailVerified` via a Timer until verification is confirmed
- Creates a corresponding Firestore user document on first signup

### `ListingProvider`
- Subscribes to Firestore `listings` collection via `snapshots()` (real-time)
- Exposes `allListings` and `myListings` (filtered by `ownerId`)
- CRUD operations delegated to `ListingService`; `notifyListeners()` called after each mutation
- Directory, My Listings, and Map View rebuild automatically on any change

---

## Project Structure

```
lib/
├── main.dart
├── theme.dart
├── models/
│   ├── listing.dart
│   └── app_user.dart
├── providers/
│   ├── auth_provider.dart
│   └── listing_provider.dart
├── services/
│   ├── auth_service.dart
│   └── listing_service.dart
└── screens/
    ├── auth/
    │   ├── login_screen.dart
    │   ├── signup_screen.dart
    │   └── email_verification_screen.dart
    ├── home/
    │   └── home_screen.dart          # BottomNavigationBar shell
    ├── directory/
    │   └── directory_screen.dart
    ├── listings/
    │   ├── my_listings_screen.dart
    │   ├── add_listing_screen.dart
    │   └── edit_listing_screen.dart
    ├── map/
    │   └── map_view_screen.dart
    ├── detail/
    │   └── listing_detail_screen.dart
    └── settings/
        └── settings_screen.dart
```

---

## Running the App

```bash
flutter pub get
flutter run
```

> Requires a connected Android device or emulator with Google Play Services installed.

---

## Navigation

Bottom navigation bar with four tabs:
1. **Directory** — all listings, search, category filter
2. **My Listings** — user-owned listings with edit/delete
3. **Map View** — Google Map with all listing markers
4. **Settings** — profile info, notification toggle, logout
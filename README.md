# Expense Tracker App

A **Personal Expense Tracker App** built with Flutter and Firebase, designed to help users manage their finances by tracking expenses and income. The app features a clean and intuitive UI, Google Authentication, local storage with SQFlite, data visualization with a pie chart, and the ability to export transaction data as a CSV file.

## Overview

The Personal Expense Tracker App is a mobile application developed as part of an assignment to demonstrate skills in Flutter and Firebase integration. The app allows users to track their expenses and income, categorize transactions, visualize financial data, and export their data for further analysis. It uses Google Authentication for secure login/signup and stores data locally using SQFlite, with user profiles synced to Firebase Firestore.

The app is designed with a focus on usability, featuring a clean Material Design UI, swipe-to-delete functionality, and a pie chart to visualize spending patterns.

## Features

- **User Authentication**:
  - Sign up and log in using Google Authentication.
  - User data (name, email) stored in Firebase Firestore.
  - Session persistence using Shared Preferences.

- **Expense and Income Tracking**:
  - Add expenses and income with categories (e.g., Food, Travel, Subscriptions, Shopping for expenses; Salary, Investment, Freelance, Passive for income).
  - Delete transactions with a swipe gesture.
  - Display all transactions in a list with details (amount, category, date).

- **Local Storage**:
  - Transactions stored locally using SQFlite in user-specific tables.
  - Data persists across app restarts.

- **Data Visualization (Bonus Feature)**:
  - Pie chart on the Budget page showing the distribution of Income, Food, Subscription, Shopping, and Travel.
  - Total amount (Income - Expenses) displayed in the center of the pie chart.

- **Export Data (Bonus Feature)**:
  - Export all transactions to a CSV file.
  - File saved to the Downloads directory on Android (requires storage permissions).
  - Confirmation dialog before exporting.

- **User Profile**:
  - View user details (name, email).
  - Options to navigate to Account, Settings, Export Data, and Logout.

- **Responsive UI**:
  - Clean and intuitive Material Design UI.
  - Consistent color scheme and typography.

## Installation

### Prerequisites
- **Flutter**: Version 3.22.2 or higher
- **Dart**: Version 3.4.3 or higher
- **Firebase Account**: For authentication and Firestore
- **Android Studio** or **VS Code** with Flutter plugins
- **Android Device/Emulator** or **iOS Simulator**

### Steps

## 1. Clone the Repository
```bash
git clone https://github.com/[YourUsername]/personal-expense-tracker.git
cd personal-expense-tracker
```

## 2. Install Dependencies
```bash
flutter pub get
```

## 3. Set Up Firebase
1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Add an **Android app** to your Firebase project:
  - Use the package name `com.example.cipher_schools_assignment`.
  - Download the `google-services.json` file and place it in `android/app/`.
3. Add an **iOS app** (optional) and configure accordingly.
4. Enable **Google Sign-In** in the Firebase Authentication settings.
5. Enable **Firestore** and set up security rules:

```plaintext
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 4. Run the App
```bash
flutter run
```

## 5. Grant Permissions (Android)
- When exporting data, the app will request storage permissions to save the CSV file to the **Downloads directory**.

## Technologies Used
- **Flutter**: Framework for building the cross-platform app.
- **Firebase**:
  - **Authentication**: Google Sign-In for user authentication.
  - **Firestore**: Storing user profiles.
- **SQFlite**: Local database for storing transactions.
- **Shared Preferences**: For session persistence.
- **FL Chart**: For creating the pie chart on the **Budget** page.
- **Riverpod**: State management for handling transactions and user data.
- **CSV**: For exporting transactions to a **CSV file**.
- **Path Provider**: For accessing file directories.
- **Permission Handler**: For requesting **storage permissions** on Android.
- **Open File**: For opening the **exported CSV file**.

## Project Structure
```plaintext
personal-expense-tracker/
├── android/                  # Android-specific files
├── ios/                      # iOS-specific files
├── lib/                      # Main source code
│   ├── constants/            # Constants (e.g., colors)
│   │   └── color_consts.dart
│   ├── helpers/              # Helper classes and services
│   │   ├── database/         # SQFlite database helper
│   │   ├── providers/        # Riverpod providers
│   │   └── services/         # Authentication service
│   ├── models/               # Data models (e.g., TransactionModel)
│   ├── screens/              # UI screens
│   │   ├── add_transcation/  # Add expense/income screens
│   │   ├── auth/             # Authentication screens
│   │   ├── budget_page.dart  # Budget overview with pie chart
│   │   ├── profile_page.dart # Profile page with export data
│   │   └── transaction_screen.dart # Transactions list
│   └── main.dart             # App entry point
├── pubspec.yaml              # Dependencies and metadata
```

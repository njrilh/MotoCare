# MotoCare 🏍️

**Motorcycle Service Management and Booking Application**

MotoCare is a motorcycle service management application designed to simplify vehicle maintenance and workshop service booking.

The system provides vehicle management, service booking, and subscription-based membership features.

## ✨ Features

- User registration and authentication.
- Vehicle data management.
- Motorcycle service booking.
- Service booking history.
- Bengkel Care subscription membership.
- Member and non-member access.
- Google Maps integration for distance-based tracking or service-related features.

## 🛠️ Tech Stack

- **Mobile Application:** Flutter, Dart
- **Backend:** Python, FastAPI
- **Database:** MySQL
- **API Communication:** REST API
- **Maps:** Google Maps API

## 🏗️ Database Design

The application uses four main database tables:

| Table | Purpose |
|---|---|
| `users` | Stores user account information |
| `vehicles` | Stores registered motorcycle data |
| `subscriptions` | Manages membership subscriptions |
| `service_bookings` | Stores service booking records |

## 🏗️ System Architecture

```text
Flutter Mobile Application
          |
          v
      REST API
          |
          v
      FastAPI
          |
          v
        MySQL
```

## 🚀 Getting Started

### Backend

```bash
pip install -r requirements.txt
uvicorn main:app --reload
```

### Flutter

```bash
flutter pub get
flutter run
```

> Update the commands and API configuration according to the actual project structure.

## 🎯 Project Goals

- Digitize motorcycle service management.
- Simplify workshop booking processes.
- Provide subscription-based service access.
- Practice mobile and backend application development.

## 👨‍💻 Author

Developed by **Nazril Hidayatulloh**.

# 🛡️ Quản Lý Thiếu Nhi (Church Child Management System)

A comprehensive, full-stack solution designed to streamline the management of church children, youth groups, and administrative workflows. This project includes a robust Node.js/TypeScript API and a versatile Flutter mobile application.

---

## 🚀 Project Overview

The **Church Child Management System** provides a centralized platform for managing:
- **People**: Detailed profiles for children, leaders, and teachers.
- **Education**: Class enrollment, attendance tracking, and academic performance.
- **Engagement**: Activity planning, feedback collection, and notifications.
- **Logistics**: QR-based check-ins and session summaries.

---

## 🛠️ Technology Stack

### Backend API (`thieunhi-api`)
- **Runtime**: [Node.js](https://nodejs.org/)
- **Framework**: [Express.js](https://expressjs.com/)
- **Language**: [TypeScript](https://www.typescriptlang.org/)
- **Database**: [PostgreSQL](https://www.postgresql.org/)
- **Security**: JWT Authentication & Bcrypt Hashing
- **Documentation**: [Swagger](https://swagger.io/) (OpenAPI 3.0)

### Mobile Application (`mobile_app`)
- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: [Dart](https://dart.dev/)

---

## ✨ Key Features

- **🔐 Secure Authentication**: Role-based access control (Admin, Leader, Teacher).
- **📋 Management Modules**: CRUD operations for Users, Children, and Classes.
- **✅ Attendance System**: Effortless session attendance tracking.
- **📊 Advanced Analytics**: Comprehensive statistics for class and overall growth.
- **📝 Feedback & Reporting**: Built-in feedback loops and term-end evaluations.
- **📲 QR Ready**: QR Code generation for seamless identification and check-ins.
- **🎨 Modern UI**: Responsive mobile interface built with Flutter.

---

## 📖 API Documentation

Our API is fully documented using **Swagger**. To explore and test the endpoints, start the backend server and navigate to:

🔗 **[http://localhost:3000/api/v1/docs](http://localhost:3000/api/v1/docs)**

---

## ⚙️ Getting Started

### Prerequisites
- **Node.js**: v14.x or higher
- **Flutter SDK**: v3.x or higher
- **PostgreSQL**: v12.x or higher

### 📦 Backend Setup
1. Navigate to the API directory:
   ```bash
   cd thieunhi-api
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Configure your environment variables in `.env`.
4. Start the development server:
   ```bash
   npm run dev
   ```

### 📱 Mobile Setup
1. Navigate to the mobile app directory:
   ```bash
   cd mobile_app/app_quan_ly_thieu_nhi
   ```
2. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

---

## 📁 Project Structure

```text
.
├── thieunhi-api/           # Node.js Express Backend
│   ├── src/
│   │   ├── config/         # System & Database configurations
│   │   ├── controllers/    # API Request handlers
│   │   ├── interfaces/     # TypeScript definitions
│   │   ├── models/         # Database access layers (SQL)
│   │   ├── routes/         # Endpoint definitions
│   │   ├── services/       # Business logic layer
│   │   └── utils/          # Shared helper functions
│   └── ...
└── mobile_app/             # Flutter Mobile Frontend
    ├── lib/
    │   ├── models/         # Client-side data models
    │   ├── services/       # API integration layer
    │   └── views/          # Flutter widget screens
    └── ...
```

---

## 👥 User Roles

| Role | Access Level | Description |
|------|--------------|-------------|
| **Admin** | Full Access | Manages system settings, users, and high-level data. |
| **Leader** | Management | Oversees groups, activities, and coordinates teachers. |
| **Teacher** | Operational | Manages classroom attendance and child interaction. |

---

© 2026 **Church Management System Team**. All rights reserved.

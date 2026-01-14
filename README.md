<div align="center">

# 📚 PDF Reader App (UAS HAQ)

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Verified-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge)](https://flutter.dev/docs/development/platform-integration/platform-channels)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](./LICENSE)

**A modern, feature-rich PDF reader built with Flutter.**  
*Experience a seamless reading journey with extensive customization, cloud sync, and a beautiful UI.*

[Report Bug](https://github.com/iRust7/uas-haq/issues) · [Request Feature](https://github.com/iRust7/uas-haq/issues)

</div>

---

## 📖 About The Project

**UAS HAQ** is a sophisticated PDF Reader application designed to provide an optimal reading experience on mobile devices. Whether you're studying lecture notes, reading novels, or reviewing documents, this app offers the tools you need in a sleek, modern package.

<details>
<summary>📋  <b>Table of Contents</b></summary>
<br>

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Screenshots](#-screenshots)
- [Installation](#-installation)
- [Usage](#-usage)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [Author](#-author)
- [License](#-license)

</details>

## ✨ Features

### 🚀 **Core Functionality**
*   **Smart Reading Modes**: Seamlessly switch between **Vertical Scroll** and **Horizontal Page Flip** with realistic 3D animations.
*   **Library Management**: Import PDFs from your device, organize them, and keep track of your reading progress.
*   **Cloud Sync**: Powered by **Firebase**, sync your user profile and reading stats across devices.

### 🎨 **User Experience**
*   **Dark Mode**: A carefully crafted dark theme to reduce eye strain during night reading.
*   **Interactive Bookmarks**: Never lose your place again. Bookmark pages and access them instantly.
*   **Progress Tracking**: Visual indicators show exactly how far you've read in each book.
*   **Custom Animations**: Smooth transitions and Lottie animations for a premium feel.

### 🔒 **Security & Authentication**
*   **Secure Login**: Support for Google Sign-In and Email/Password authentication via Firebase Auth.
*   **Private Data**: User specific data isolation using Cloud Firestore.

## 🛠 Tech Stack

This project is built using a robust selection of modern technologies:

| Category | Technology | Badge |
|----------|------------|-------|
| **Framework** | Flutter | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white) |
| **Language** | Dart | ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white) |
| **Backend** | Firebase | ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black) |
| **Auth** | Firebase Auth | ![Firebase Auth](https://img.shields.io/badge/Auth-FFCA28?style=flat-square&logo=firebase&logoColor=black) |
| **Database** | Cloud Firestore | ![Firestore](https://img.shields.io/badge/Firestore-FFCA28?style=flat-square&logo=firebase&logoColor=black) |
| **Local DB** | Hive | ![Hive](https://img.shields.io/badge/Hive-NoSQL-red?style=flat-square) |
| **Animations** | Lottie | ![Lottie](https://img.shields.io/badge/Lottie-Animations-00ADB5?style=flat-square&logo=lottie&logoColor=white) |

## 📸 Screenshots

| Home & Library | Reading View | Dark Mode | Profile |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/home.png" alt="Home" width="200"/> | <img src="docs/screenshots/reader.png" alt="Reader" width="200"/> | <img src="docs/screenshots/dark_mode.png" alt="Dark Mode" width="200"/> | <img src="docs/screenshots/profile.png" alt="Profile" width="200"/> |
> *Note: Screenshots to be added.*

## 📦 Installation

Follow these steps to get a local copy up and running.

### Prerequisites

*   **Flutter SDK**: [Install Flutter](https://flutter.dev/docs/get-started/install)
*   **Git**: [Install Git](https://git-scm.com/downloads)

### Setup Steps

1.  **Clone the Repo**
    ```sh
    git clone https://github.com/iRust7/uas-haq.git
    cd uas-haq
    ```

2.  **Install Dependencies**
    ```sh
    flutter pub get
    ```

3.  **Firebase Setup**
    *   Create a project on [Firebase Console](https://console.firebase.google.com/).
    *   Add an Android app and download `google-services.json`.
    *   Place `google-services.json` in `android/app/`.
    *   Enable **Authentication** (Google & Email) and **Firestore**.

4.  **Run the App**
    ```sh
    flutter run
    ```

## 📂 Project Structure

The project follows a feature-first architecture for scalability and maintainability.

```bash
lib/
├── core/                   # ⚙️ Core configurations (Theme, Services)
├── data/
│   ├── models/             # 📦 Data Models (Book, User)
│   └── repositories/       # 🗄️ Repositories (Data Access)
├── features/
│   ├── auth/               # 🔐 Authentication Pages
│   ├── home/               # 🏠 Home & Library
│   ├── reader/             # 📖 PDF Reader (Core Feature)
│   ├── statistics/         # 📊 Reading Statistics
│   └── splash/             # 🎬 Splash Screen
└── routes/                 # 🛣️ App Navigation
```

## 🤝 Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 👨‍💻 Author

**HAQ** - *Mobile Developer*

*   GitHub: [@iRust7](https://github.com/iRust7)
*   Instagram: [@haq.dev](https://instagram.com)

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<div align="center">
  <p>Made with ❤️ using Flutter</p>
</div>

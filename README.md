# Hamro Class 📚📱

**Hamro Class** is a Flutter-based mobile application designed to streamline communication within college classrooms. It acts as a digital bridge between Students and Class Representatives (CRs), ensuring that important updates, polls, and events are always just a tap away.

---

## 🔗 GitHub Repository

[Hamro_Class on GitHub](https://github.com/sumangiri109/Hamro_Class)

---

## 🚀 Features

### 🔐 Login & Signup System
- KU email-based registration only
- Email verification is required before login

### 🎭 Role-based Interface
- **Students**: View information only
- **CRs**: Add, Edit, and Delete entries (automatically identified via email)

### 📢 Announcements
- Subject-wise announcements
- Optional PDF/image attachments
- "(edited)" label shown if the post is updated
- Only one post can be edited at a time

### 🗳️ Polls and Voting
- CRs post polls with custom options
- Students vote once per poll
- Real-time poll result updates using Firestore

### 💬 General Chat
- Class-wide group chat
- Each message shows sender's email
- Real-time sync using Firestore

### 🗓️ Routine and Events
- Placeholder pages for class schedules and event notifications
- Designed for future expansion

### 📎 File Uploads
- CRs can upload PDFs and images to Firebase Storage
- File links and names are stored in Firestore

### ☁️ Real-time Updates
- Powered by Cloud Firestore

### 🌙 Dark Mode *(planned)*

### 📥 Push Notifications *(planned)*

### 📚 Resource Sharing *(future feature)*

### 🕒 Attendance Tracker *(future feature)*

---

## 🛠️ Tech Stack

- **Frontend**: Flutter  
- **Authentication**: Firebase Auth  
- **Database**: Cloud Firestore  
- **Storage**: Firebase Storage  
- **State Management**: *(Add if applicable, e.g., Provider, Riverpod)*

---

## 📁 Project Structure

lib/
├── core/ # Configuration and Firebase setup
├── features/ # UI and logic for each feature (announcements, polls, etc.)
├── models/ # Data models
├── services/ # Firebase and backend logic
└── widgets/ # Reusable UI components

yaml
Copy
Edit

---

## 🔧 How to Run

```bash
1️⃣ . Clone the Repository
git clone https://github.com/sumangiri109/Hamro_Class.git

2️⃣ . Navigate to the Project Folder
bash
Copy
Edit
cd Hamro_Class

3️⃣ . Get the Dependencies
bash
Copy
Edit
flutter pub get
4️⃣ . Connect Firebase
Add your google-services.json file inside android/app/
Add your GoogleService-Info.plist file inside ios/Runner/

Enable the following in the Firebase Console:
Email/Password Authentication
Cloud Firestore
Firebase Storage

5️⃣ . Run the App
bash
Copy
Edit
flutter run
```

🤝 Contributing:
Do you have an idea, or have you found a bug?
Feel free to open an issue or submit a pull request!

📧 Contact:
If you're from KU and having trouble:

Check your spam folder for the verification email

If you signed up earlier, please sign up again using the new system

Contact us directly to help us test and improve

Made with ❤️ by Suman Giri and Team


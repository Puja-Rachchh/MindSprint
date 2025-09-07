# 📱 Flutter Barcode Scanner with Firebase  

[![Flutter](https://img.shields.io/badge/Flutter-3.22-blue?logo=flutter)](https://flutter.dev/)  
[![Firebase](https://img.shields.io/badge/Firebase-Authentication-orange?logo=firebase)](https://firebase.google.com/)  

A **Flutter mobile application** that allows users to **scan product barcodes** and instantly view all **ingredients** of that product. The app includes **Firebase authentication** for secure login/sign-up and provides a **dashboard & detail screen** for displaying product information.  


https://github.com/user-attachments/assets/652afd52-e0be-450f-a8e7-6cdbfa913fcb


---

## 🚀 Features  
- 🔑 **User Authentication** (Firebase)  
  - Login & Sign-up with Email/Password  

- 📷 **Barcode Scanner**  
  - Scan product barcodes using the phone camera  
  - Instantly fetch and display product ingredients  

- 📊 **Dashboard Screen**  
  - Shows scanned product history or recent searches  

- 📄 **Detail Screen**  
  - Displays detailed product info & ingredients list  

- 🎨 **Modern UI**  
  - Clean, responsive interface  
  - Smooth navigation between Login → Dashboard → Detail  

---

## 🛠️ Tech Stack  
- [Flutter](https://flutter.dev/) (Dart)  
- [Firebase Authentication](https://firebase.google.com/docs/auth)  
- [Firebase Core](https://pub.dev/packages/firebase_core)  
- [barcode_scan2](https://pub.dev/packages/barcode_scan2) or [ML Kit](https://developers.google.com/ml-kit/vision/barcode-scanning) for scanning  

---

## 📂 Project Structure  
lib/

│── main.dart # Entry point of the app

│── Login_Screen.dart # User login page

│── Signin_Screen.dart # User registration page

│── Dashboard_Screen.dart # Dashboard after login

│── Detail_Screen.dart # Product details (ingredients)


---

## ⚙️ Installation & Setup  

### 1️⃣ Clone the repository  
```bash
git clone https://github.com/your-username/flutter-barcode-scanner.git
cd flutter-barcode-scanner
```
### 2️⃣ Install dependencies
```bash
flutter pub get
```

### 3️⃣ Configure Firebase
- Go to Firebase Console

- Create a project → add Android/iOS app

- Download google-services.json → place in android/app/

- Download GoogleService-Info.plist → place in ios/Runner/

- Enable Authentication → Email/Password

### 4️⃣ Run the app
```bash
flutter run
```

🧑‍💻 Author

Developed with ❤️ by Team MindSpirit



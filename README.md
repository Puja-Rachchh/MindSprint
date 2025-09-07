# NutriGo - Nutrition Tracker App 🥗📱

A comprehensive Flutter-based nutrition tracking application that helps users make informed dietary decisions through barcode scanning, image recognition, and personalized allergen warnings, powered by Firebase backend.

https://github.com/user-attachments/assets/652afd52-e0be-450f-a8e7-6cdbfa913fcb

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

## 🌟 Features

### 🔍 Product Scanning
- **Barcode Scanner**: Real-time barcode scanning using device camera
- **Image Upload**: Upload product images from gallery for barcode detection
- **Multi-format Support**: Supports various barcode formats including EAN-13
- **Instant Recognition**: Quick product identification and nutritional data retrieval

### 📊 Nutritional Information
- **Detailed Nutrition Facts**: Comprehensive nutritional breakdown per 100g
- **Key Metrics**: Calories, proteins, fats, carbohydrates, fiber, sugars, sodium
- **Visual Presentation**: Clean, easy-to-read nutritional information display
- **Real-time Data**: Live data from Nutritionix API database

### ⚠️ Allergen Detection & Warnings
- **Personal Allergen Profiles**: Customizable allergen preferences
- **Instant Alerts**: Real-time allergen warnings based on user profile
- **Visual Warnings**: Clear, color-coded allergen information
- **Comprehensive Coverage**: Supports major allergens (dairy, nuts, gluten, etc.)

### 🍽️ Diet Planning
- **Personalized Plans**: Custom diet plans based on user preferences
- **Notification System**: Optional reminders for meal planning
- **Progress Tracking**: Monitor dietary goals and achievements
- **Flexible Options**: Accommodate various dietary restrictions

### 👤 User Management
- **Firebase Authentication**: Secure user registration and login
- **Cloud Storage**: Real-time user data synchronization
- **Profile Management**: Comprehensive health metrics tracking
- **Demo Account**: Quick access with pre-configured demo user
- **Cross-device Sync**: Access your data from multiple devices

### ☁️ Firebase Backend Integration
- **Firestore Database**: Real-time NoSQL database for user profiles and scan history
- **Firebase Auth**: Secure authentication with email/password
- **Cloud Storage**: Store user profile images and scan history
- **Real-time Sync**: Instant data synchronization across devices
- **Offline Support**: Works offline with automatic sync when connected

## 🛠️ Technical Stack

### Frontend
- **Framework**: Flutter (Latest stable version)
- **Language**: Dart
- **State Management**: StatefulWidget with setState
- **UI Components**: Material Design

### Backend & Cloud Services
- **Firebase Authentication**: User authentication and security
- **Cloud Firestore**: NoSQL database for user data and scan history
- **Firebase Storage**: Cloud storage for images and assets
- **Firebase Analytics**: User behavior tracking and insights

### APIs & Services
- **Nutritionix API**: Food database and nutritional information
- **Mobile Scanner**: Barcode scanning functionality
- **Google ML Kit**: Image processing and barcode detection
- **Image Picker**: Gallery and camera image selection

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  # Scanning & Image Processing
  mobile_scanner: ^3.5.2
  image_picker: ^1.0.4
  google_mlkit_barcode_scanning: ^0.9.0
  
  # Networking
  http: ^1.1.0
  
  # Permissions
  permission_handler: ^11.0.1
  
  # Firebase
  firebase_core: ^2.15.1
  firebase_auth: ^4.7.3
  cloud_firestore: ^4.8.5
  firebase_storage: ^11.2.6
  firebase_analytics: ^10.4.5
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- Android Studio / VS Code
- Android/iOS device or emulator
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Puja-Rachchh/MindSprint.git
   cd MindSprint
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS app to your Firebase project
   - Download and add configuration files:
     - `google-services.json` for Android (place in `android/app/`)
     - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
   - Enable Authentication and Firestore in Firebase Console

4. **Configure API Keys**
   - Obtain Nutritionix API credentials
   - Update API keys in `Dashboard_Screen.dart`:
   ```dart
   final String nutritionixAppId = 'YOUR_APP_ID';
   final String nutritionixApiKey = 'YOUR_API_KEY';
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

### Firebase Configuration

1. **Authentication Setup**
   - Enable Email/Password authentication in Firebase Console
   - Configure sign-in methods as needed


## 🔑 Key Features Implementation

### Firebase Authentication
```dart
// User authentication
final FirebaseAuth _auth = FirebaseAuth.instance;
await _auth.signInWithEmailAndPassword(
  email: email,
  password: password,
);
```

### Firestore Integration
```dart
// Save user data
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .set(userData);
```

### Barcode Scanning
```dart
// Initialize camera for scanning
mobile_scanner.MobileScannerController(
  detectionSpeed: DetectionSpeed.noDuplicates,
  facing: CameraFacing.back,
  formats: [BarcodeFormat.ean13],
)
```

### API Integration
```dart
// Fetch nutritional data
final response = await http.get(
  Uri.parse('https://trackapi.nutritionix.com/v2/search/item?upc=$barcode'),
  headers: {
    'x-app-id': nutritionixAppId,
    'x-app-key': nutritionixApiKey,
  },
);
```

## 🎯 Usage

1. **First Launch**: Complete onboarding and create Firebase account
2. **Profile Setup**: Enter personal health information synced to Firestore
3. **Scan Products**: Use camera to scan barcodes or upload images
4. **View Results**: Get detailed nutritional information and allergen warnings
5. **Diet Planning**: Set up personalized meal plans stored in Firebase
6. **Cross-device Access**: Login from any device to access your data

## 🔒 Security & Privacy

- **Firebase Authentication**: Industry-standard security protocols
- **Encrypted Data**: All user data encrypted in transit and at rest
- **Privacy Controls**: Users control their data sharing preferences
- **GDPR Compliant**: Built with privacy regulations in mind

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🔮 Future Enhancements

- [ ] Advanced Firebase Analytics integration
- [ ] Push notifications via Firebase Cloud Messaging
- [ ] Social features with Firestore real-time updates
- [ ] Machine learning recommendations using Firebase ML
- [ ] Multi-language support with Firebase Remote Config
- [ ] A/B testing with Firebase
- [ ] Crashlytics integration for better error tracking
- [ ] Performance monitoring with Firebase Performance

---

*Transform your eating habits with intelligent nutrition tracking powered by the cloud!*




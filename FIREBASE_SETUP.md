# Firebase Integration Guide for CampusLink

Follow these step-by-step instructions to connect your **CampusLink** Flutter app with your personal Firebase project.

---

## Step 1: Create a Firebase Project

1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project**, enter `CampusLink`, and complete the configuration steps (Google Analytics is optional).
3. Enable the following services in the console:
   * **Authentication**: Go to *Build > Authentication > Get Started*. Enable **Email/Password** sign-in provider.
   * **Cloud Firestore**: Go to *Build > Firestore Database > Create Database*. Start in **test mode** or define rules (see Step 3). Select a close location.
   * **Cloud Storage**: Go to *Build > Storage > Get Started*. Choose default settings.
   * **Cloud Messaging (Optional)**: For push notifications, navigate to *Project Settings > Cloud Messaging* to configure certificates or keys.

---

## Step 2: Configure Firebase via FlutterFire CLI

The recommended way to link your Flutter application to Firebase is using the **FlutterFire CLI**:

1. Install the Firebase CLI on your system (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```
2. Log into your Firebase account from the terminal:
   ```bash
   firebase login
   ```
3. Install the FlutterFire CLI globally:
   ```bash
   dart pub global activate flutterfire_cli
   ```
4. Run the configuration command in the root directory of this project:
   ```bash
   flutterfire configure --project=campus-link-app
   ```
   *(Replace `campus-link-app` with your actual Firebase Project ID).*
5. Select the target platforms (Android, iOS, Web) by pressing Spacebar, then press Enter.
6. The CLI will automatically create/overwrite `lib/firebase_options.dart` with your real keys.

---

## Step 3: Configure Database & Storage Security Rules

Copy these rules into the respective tabs in the Firebase console:

### 1. Cloud Firestore Rules
Ensure users can only modify their own posts, comments, and profiles, and allow general reads for logged-in students:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Check if user is operating on their own data
    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    // Users Collection rules
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && isOwner(userId);
    }

    // Posts Collection rules
    match /posts/{postId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && request.resource.data.authorId == request.auth.uid;
      allow update: if isAuthenticated() && resource.data.authorId == request.auth.uid;
      allow delete: if isAuthenticated() && resource.data.authorId == request.auth.uid;
    }

    // Comments Collection rules
    match /comments/{commentId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && request.resource.data.authorId == request.auth.uid;
      allow delete: if isAuthenticated() && resource.data.authorId == request.auth.uid;
    }

    // Notifications Collection rules
    match /notifications/{notificationId} {
      allow read: if isAuthenticated() && resource.data.receiverId == request.auth.uid;
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && resource.data.receiverId == request.auth.uid;
    }
  }
}
```

### 2. Cloud Storage Rules
Ensure image uploads are safe and restricted to image file formats:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    function isAuthenticated() {
      return request.auth != null;
    }

    // Rules for user profile photos
    match /profiles/{userId}.jpg {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && request.auth.uid == userId
                   && request.resource.contentType.matches('image/.*');
    }

    // Rules for posts photos
    match /posts/{userId}/{allPaths=**} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && request.auth.uid == userId
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

---

## Step 4: Run the Application

Once configured:
1. Connect a physical device or open a virtual simulator.
2. Start the dev server:
   ```bash
   flutter run
   ```

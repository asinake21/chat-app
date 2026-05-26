class AppConstants {
  static const String appName = 'CampusLink';

  // Firebase Firestore Collection Names
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String commentsCollection = 'comments';
  static const String notificationsCollection = 'notifications';

  // Shared Preferences / Local Storage keys
  static const String themeKey = 'is_dark_mode';

  // Default Asset/Image URLs (Using premium, royalty-free student UI placeholder illustrations)
  static const String defaultProfilePicture = '';
  static const String defaultPostPlaceholder = 
      'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?auto=format&fit=crop&q=80&w=600';

  // UI Paddings and Margins
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double borderRadiusLarge = 20.0;
}

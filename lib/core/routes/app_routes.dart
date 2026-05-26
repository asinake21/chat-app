import 'package:flutter/material.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/create_post_screen.dart';
import '../../screens/home/post_detail_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/notifications/notification_screen.dart';
import '../../screens/settings/settings_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String createPost = '/create-post';
  static const String postDetail = '/post-detail';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      home: (context) => const HomeScreen(),
      createPost: (context) => const CreatePostScreen(),
      postDetail: (context) => const PostDetailScreen(),
      profile: (context) => const ProfileScreen(),
      notifications: (context) => const NotificationScreen(),
      settings: (context) => const SettingsScreen(),
    };
  }
}

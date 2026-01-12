import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/main/main_screen.dart';

/// AppRoutes - Definisi named routes aplikasi
/// 
/// Menggunakan named routes untuk navigasi yang konsisten
/// dan mudah di-maintain.
class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  
  // TODO: Routes untuk iterasi berikutnya
  // static const String bookDetail = '/book-detail';
  // static const String bookForm = '/book-form';
  // static const String reader = '/reader';
  
  /// Mendapatkan semua routes aplikasi
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      main: (context) => const MainScreen(),
    };
  }
  
  // Private constructor
  AppRoutes._();
}

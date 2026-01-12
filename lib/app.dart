import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'routes/app_routes.dart';

/// MyApp - Root widget aplikasi
/// 
/// Menggunakan MaterialApp dengan:
/// - AppTheme untuk styling konsisten (light & dark)
/// - ThemeProvider untuk dynamic theme switching
/// - Named routes untuk navigasi
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.loadTheme();
    _themeProvider.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Library',
      debugShowCheckedModeBanner: false,
      
      // Tema aplikasi (light & dark)
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeProvider.themeMode,
      
      // Route awal
      initialRoute: AppRoutes.splash,
      
      // Daftar routes
      routes: AppRoutes.getRoutes(),
      
      // Provide theme to MaterialApp widget tree
      builder: (context, child) {
        return ThemeProviderWidget(
          provider: _themeProvider,
          child: child!,
        );
      },
    );
  }
}

/// ThemeProviderWidget - InheritedWidget untuk akses ThemeProvider
class ThemeProviderWidget extends InheritedWidget {
  final ThemeProvider provider;

  const ThemeProviderWidget({
    super.key,
    required this.provider,
    required super.child,
  });

  static ThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProviderWidget>()?.provider;
  }

  @override
  bool updateShouldNotify(ThemeProviderWidget oldWidget) {
    return provider != oldWidget.provider;
  }
}

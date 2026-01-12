import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../data/repositories/session_repository.dart';
import '../../routes/app_routes.dart';

/// SplashScreen - Layar awal aplikasi
/// 
/// Fungsi:
/// 1. Menampilkan logo/nama aplikasi
/// 2. Mengecek session login dari Hive
/// 3. Auto login sebagai guest jika belum ada session
/// 4. Redirect ke Library
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  /// Cek session dan navigate ke Library
  /// 
  /// Jika tidak ada session, auto login sebagai guest
  Future<void> _checkSessionAndNavigate() async {
    // Delay untuk menampilkan splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Cek session dari Hive
    final sessionRepo = SessionRepository();
    final isLoggedIn = sessionRepo.isLoggedIn();
    
    // Jika belum ada session, login sebagai guest
    if (!isLoggedIn) {
      await sessionRepo.loginAsGuest();
    }
    
    if (!mounted) return;
    
    // Navigate ke Library (guest atau logged user)
    Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            Lottie.asset(
              'assets/animations/iconsplash.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
            ),
            const SizedBox(height: 24),
            
            // Nama aplikasi
            Text(
              'Book Library',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              'PDF Reader Offline',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../core/services/firestore_service.dart';

/// SessionRepository - Mengelola session login dan registrasi pengguna
/// 
/// Menggunakan Firebase Authentication dan Firestore Database
/// Dengan Hive sebagai cache lokal
class SessionRepository {
  static const String _sessionBoxName = 'user';
  static const String _currentUserKey = 'current_user';
  
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  /// Mengecek apakah user sudah login
  bool isLoggedIn() {
    // Cek Firebase Auth dulu
    if (_authService.currentUser != null) {
      return true;
    }
    
    // Fallback ke Hive cache
    final box = Hive.box<User>(_sessionBoxName);
    final user = box.get(_currentUserKey);
    return user != null && user.isLoggedIn;
  }
  
  /// Mengecek apakah current user adalah guest
  bool isGuest() {
    // Guest tidak ada di Firebase
    if (_authService.currentUser != null) {
      return false;
    }
    
    final box = Hive.box<User>(_sessionBoxName);
    final user = box.get(_currentUserKey);
    return user != null && user.isGuest;
  }
  
  /// Mendapatkan username yang tersimpan
  String? getUsername() {
    // Cek Firebase Auth dulu
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      return firebaseUser.displayName ?? firebaseUser.email?.split('@')[0];
    }
    
    final box = Hive.box<User>(_sessionBoxName);
    final user = box.get(_currentUserKey);
    return user?.username;
  }
  
  /// Mendapatkan User object
  User? getCurrentUser() {
    final box = Hive.box<User>(_sessionBoxName);
    return box.get(_currentUserKey);
  }
  
  /// Login sebagai guest
  /// 
  /// Digunakan untuk first launch atau continue as guest
  Future<bool> loginAsGuest() async {
    try {
      final box = Hive.box<User>(_sessionBoxName);
      final guestUser = User.createGuest();
      await box.put(_currentUserKey, guestUser);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Registrasi user baru dengan Firebase Auth
  /// 
  /// Menggunakan Email/Password authentication
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Register ke Firebase Auth
      final result = await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      if (!result['success']) {
        return result;
      }
      
      final firebaseUser = result['user'] as firebase_auth.User;
      
      // Simpan ke Firestore
      await _firestoreService.saveUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        authProvider: 'email',
      );
      
      // Simpan ke Hive cache
      final user = User.fromFirebase(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        authProvider: 'email',
      );
      
      final box = Hive.box<User>(_sessionBoxName);
      await box.put(_currentUserKey, user);
      
      return {
        'success': true,
        'message': 'Registrasi berhasil',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
  
  /// Login dengan Email dan Password menggunakan Firebase Auth
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Login ke Firebase Auth
      final result = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (!result['success']) {
        return result;
      }
      
      final firebaseUser = result['user'] as firebase_auth.User;
      
      // Update last login di Firestore
      await _firestoreService.updateLastLogin(firebaseUser.uid);
      
      // Simpan ke Hive cache
      final user = User.fromFirebase(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        authProvider: 'email',
      );
      
      final box = Hive.box<User>(_sessionBoxName);
      await box.put(_currentUserKey, user);
      
      return {
        'success': true,
        'message': 'Login berhasil',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
  
  /// Login dengan Google
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      // Login dengan Google
      final result = await _authService.signInWithGoogle();
      
      if (!result['success']) {
        return result;
      }
      
      final firebaseUser = result['user'] as firebase_auth.User;
      
      // Simpan/update di Firestore
      await _firestoreService.saveUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        authProvider: 'google',
      );
      
      // Simpan ke Hive cache
      final user = User.fromFirebase(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        authProvider: 'google',
      );
      
      final box = Hive.box<User>(_sessionBoxName);
      await box.put(_currentUserKey, user);
      
      return {
        'success': true,
        'message': 'Login dengan Google berhasil',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
  
  /// Menghapus session (logout)
  /// 
  /// Logout dari Firebase dan kembali ke guest mode
  Future<bool> logout() async {
    try {
      // Logout dari Firebase
      await _authService.signOut();
      
      // Logout dan auto login sebagai guest
      await loginAsGuest();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Reset password dengan Firebase Auth
  Future<Map<String, dynamic>> resetPassword(String email) async {
    return await _authService.resetPassword(email);
  }
}

import 'package:hive/hive.dart';
import '../models/user.dart';

/// SessionRepository - Mengelola session login dan registrasi pengguna
/// 
/// Menggunakan Hive dengan 2 boxes:
/// - Box 'user': current session
/// - Box 'users': semua registered users
class SessionRepository {
  static const String _sessionBoxName = 'user';
  static const String _usersBoxName = 'users';
  static const String _currentUserKey = 'current_user';
  
  /// Mengecek apakah user sudah login
  bool isLoggedIn() {
    final box = Hive.box<User>(_sessionBoxName);
    final user = box.get(_currentUserKey);
    return user != null && user.isLoggedIn;
  }
  
  /// Mengecek apakah current user adalah guest
  bool isGuest() {
    final box = Hive.box<User>(_sessionBoxName);
    final user = box.get(_currentUserKey);
    return user != null && user.isGuest;
  }
  
  /// Mendapatkan username yang tersimpan
  String? getUsername() {
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
  
  /// Registrasi user baru
  /// 
  /// Validasi:
  /// - Username tidak boleh "Guest" (reserved)
  /// - Username harus unique
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
  }) async {
    try {
      // Validasi username tidak boleh "Guest"
      if (username.toLowerCase() == 'guest') {
        return {
          'success': false,
          'message': 'Username "Guest" tidak diperbolehkan',
        };
      }
      
      // Cek apakah username sudah ada
      final usersBox = Hive.box<User>(_usersBoxName);
      if (usersBox.containsKey(username)) {
        return {
          'success': false,
          'message': 'Username sudah terdaftar',
        };
      }
      
      // Buat user baru dan simpan ke users box
      final newUser = User.createRegistered(
        username: username,
        password: password,
      );
      await usersBox.put(username, newUser);
      
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
  
  /// Login dengan username dan password
  /// 
  /// Validasi password dan set sebagai current session
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final usersBox = Hive.box<User>(_usersBoxName);
      
      // Cek apakah user terdaftar
      if (!usersBox.containsKey(username)) {
        return {
          'success': false,
          'message': 'Username tidak ditemukan',
        };
      }
      
      // Get user dan validasi password
      final user = usersBox.get(username);
      if (user == null || user.password != password) {
        return {
          'success': false,
          'message': 'Password salah',
        };
      }
      
      // Update last login dan set sebagai current session
      user.lastLoginAt = DateTime.now();
      user.isLoggedIn = true;
      await user.save(); // Save to users box
      
      final sessionBox = Hive.box<User>(_sessionBoxName);
      await sessionBox.put(_currentUserKey, user);
      
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
  
  /// Menghapus session (logout)
  /// 
  /// Kembali ke guest mode setelah logout
  Future<bool> logout() async {
    try {
      // Logout dan auto login sebagai guest
      await loginAsGuest();
      return true;
    } catch (e) {
      return false;
    }
  }
}

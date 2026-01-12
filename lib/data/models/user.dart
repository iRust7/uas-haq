import 'package:hive/hive.dart';

part 'user.g.dart';

/// User Model - Data pengguna untuk session dan registrasi
/// 
/// Menggunakan Hive untuk penyimpanan lokal.
/// TypeId 0 untuk User adapter.
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String username;
  
  @HiveField(1)
  DateTime lastLoginAt;
  
  @HiveField(2)
  bool isLoggedIn;
  
  @HiveField(3)
  String? password; // null untuk guest user
  
  @HiveField(4)
  bool isGuest;
  
  @HiveField(5)
  String? email; // Email untuk Firebase Auth
  
  @HiveField(6)
  String? displayName; // Display name dari provider
  
  @HiveField(7)
  String? photoURL; // Photo URL dari provider (Google)
  
  @HiveField(8)
  String? authProvider; // 'email', 'google', atau 'guest'
  
  @HiveField(9)
  String? uid; // Firebase Auth UID
  
  User({
    required this.username,
    required this.lastLoginAt,
    this.isLoggedIn = true,
    this.password,
    this.isGuest = false,
    this.email,
    this.displayName,
    this.photoURL,
    this.authProvider,
    this.uid,
  });
  
  /// Factory untuk membuat guest user
  factory User.createGuest() {
    return User(
      username: 'Guest',
      lastLoginAt: DateTime.now(),
      isLoggedIn: true,
      password: null,
      isGuest: true,
      authProvider: 'guest',
    );
  }
  
  /// Factory untuk membuat registered user
  factory User.createRegistered({
    required String username,
    required String password,
  }) {
    return User(
      username: username,
      lastLoginAt: DateTime.now(),
      isLoggedIn: true,
      password: password,
      isGuest: false,
      authProvider: 'email',
    );
  }
  
  /// Factory untuk membuat user dari Firebase Auth
  factory User.fromFirebase({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
    required String authProvider,
  }) {
    return User(
      uid: uid,
      username: displayName ?? email.split('@')[0],
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      lastLoginAt: DateTime.now(),
      isLoggedIn: true,
      isGuest: false,
      authProvider: authProvider,
    );
  }
  
  @override
  String toString() {
    return 'User(username: $username, email: $email, isGuest: $isGuest, authProvider: $authProvider, lastLoginAt: $lastLoginAt)';
  }
}

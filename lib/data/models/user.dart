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
  
  User({
    required this.username,
    required this.lastLoginAt,
    this.isLoggedIn = true,
    this.password,
    this.isGuest = false,
  });
  
  /// Factory untuk membuat guest user
  factory User.createGuest() {
    return User(
      username: 'Guest',
      lastLoginAt: DateTime.now(),
      isLoggedIn: true,
      password: null,
      isGuest: true,
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
    );
  }
  
  @override
  String toString() {
    return 'User(username: $username, isGuest: $isGuest, lastLoginAt: $lastLoginAt)';
  }
}

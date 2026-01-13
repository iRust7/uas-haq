import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing user avatar preferences
/// Stores the selected avatar type (male/female)
class AvatarRepository {
  static const String _avatarKey = 'user_avatar_type';
  static const String defaultAvatar = 'male';
  
  /// Get the current avatar type
  /// Returns 'male' or 'female'
  /// Default is 'male' for guests
  Future<String> getAvatarType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_avatarKey) ?? defaultAvatar;
    } catch (e) {
      return defaultAvatar;
    }
  }
  
  /// Set the avatar type
  /// @param avatarType - 'male' or 'female'
  Future<bool> setAvatarType(String avatarType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_avatarKey, avatarType);
    } catch (e) {
      return false;
    }
  }
  
  /// Reset avatar to default (male)
  Future<bool> resetAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_avatarKey);
    } catch (e) {
      return false;
    }
  }
}

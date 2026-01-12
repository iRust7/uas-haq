/// Validators - Fungsi validasi untuk form input
/// 
/// Digunakan untuk validasi di LoginScreen dan form lainnya.
class Validators {
  /// Validasi username
  /// - Tidak boleh kosong
  /// - Minimal 3 karakter
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Username minimal 3 karakter';
    }
    return null; // Valid
  }
  
  /// Validasi password
  /// - Tidak boleh kosong
  /// - Minimal 3 karakter
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Password minimal 3 karakter';
    }
    return null; // Valid
  }
  
  /// Validasi field tidak boleh kosong (generic)
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null; // Valid
  }
  
  // Private constructor
  Validators._();
}

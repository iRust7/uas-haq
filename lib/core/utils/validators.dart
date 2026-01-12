/// Validators - Fungsi validasi untuk form input
/// 
/// Digunakan untuk validasi di LoginScreen, RegisterScreen dan form lainnya.
class Validators {
  /// Validasi email
  /// - Tidak boleh kosong
  /// - Harus format email yang valid
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email tidak valid';
    }
    
    return null; // Valid
  }
  
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
  /// - Minimal 6 karakter (Firebase requirement)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
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

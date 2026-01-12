import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

/// FirebaseAuthService - Service untuk handle Firebase Authentication
/// 
/// Mendukung:
/// - Email/Password authentication
/// - Google Sign-In
/// - Auto sign out dan sign in
class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  /// Get current Firebase user
  firebase_auth.User? get currentUser => _auth.currentUser;
  
  /// Stream untuk listen perubahan auth state
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();
  
  /// Register dengan Email dan Password
  Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name jika ada
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
        await credential.user?.reload();
      }
      
      return {
        'success': true,
        'message': 'Registrasi berhasil',
        'user': credential.user,
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = 'Registrasi gagal';
      switch (e.code) {
        case 'weak-password':
          message = 'Password terlalu lemah';
          break;
        case 'email-already-in-use':
          message = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          message = 'Email tidak valid';
          break;
        default:
          message = e.message ?? 'Registrasi gagal';
      }
      
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
  
  /// Login dengan Email dan Password
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return {
        'success': true,
        'message': 'Login berhasil',
        'user': credential.user,
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = 'Login gagal';
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak ditemukan';
          break;
        case 'wrong-password':
          message = 'Password salah';
          break;
        case 'invalid-email':
          message = 'Email tidak valid';
          break;
        case 'user-disabled':
          message = 'Akun telah dinonaktifkan';
          break;
        case 'invalid-credential':
          message = 'Email atau password salah';
          break;
        default:
          message = e.message ?? 'Login gagal';
      }
      
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
  
  /// Sign In dengan Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return {
          'success': false,
          'message': 'Login dibatalkan',
        };
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      return {
        'success': true,
        'message': 'Login dengan Google berhasil',
        'user': userCredential.user,
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = 'Login dengan Google gagal';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = 'Akun sudah ada dengan metode login berbeda';
          break;
        case 'invalid-credential':
          message = 'Kredensial tidak valid';
          break;
        case 'operation-not-allowed':
          message = 'Login dengan Google belum diaktifkan';
          break;
        case 'user-disabled':
          message = 'Akun telah dinonaktifkan';
          break;
        default:
          message = e.message ?? 'Login dengan Google gagal';
      }
      
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
  
  /// Sign Out
  Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Reset Password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Email reset password telah dikirim',
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = 'Reset password gagal';
      switch (e.code) {
        case 'invalid-email':
          message = 'Email tidak valid';
          break;
        case 'user-not-found':
          message = 'Email tidak ditemukan';
          break;
        default:
          message = e.message ?? 'Reset password gagal';
      }
      
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}

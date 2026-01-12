import 'package:cloud_firestore/cloud_firestore.dart';

/// FirestoreService - Service untuk handle Firestore Database
/// 
/// Menyimpan data user di collection 'users'
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Collection name untuk users
  static const String usersCollection = 'users';
  
  /// Menyimpan atau update user data di Firestore
  Future<bool> saveUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
    required String authProvider,
  }) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).set({
        'email': email,
        'displayName': displayName ?? email.split('@')[0],
        'photoURL': photoURL,
        'authProvider': authProvider,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      return true;
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }
  
  /// Mengambil user data dari Firestore
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
  
  /// Update last login timestamp
  Future<bool> updateLastLogin(String uid) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating last login: $e');
      return false;
    }
  }
  
  /// Update user profile
  Future<bool> updateUserProfile({
    required String uid,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoURL != null) updates['photoURL'] = photoURL;
      
      if (updates.isNotEmpty) {
        await _firestore.collection(usersCollection).doc(uid).update(updates);
      }
      
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
  
  /// Delete user data
  Future<bool> deleteUser(String uid) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).delete();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
  
  /// Stream untuk listen user data changes
  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(String uid) {
    return _firestore.collection(usersCollection).doc(uid).snapshots();
  }
}

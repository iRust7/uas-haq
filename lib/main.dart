import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'data/models/user.dart';
import 'data/models/book.dart';
import 'data/models/reading_session.dart';
import 'data/repositories/starred_folders_repository.dart';

/// Entry point aplikasi
/// 
/// Initialize Firebase, Hive dengan 3 boxes dan run MyApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(ReadingSessionAdapter());
  
  // Open boxes
  await Hive.openBox<User>('user');      // Current session box
  await Hive.openBox<Book>('books');     // All books box
  await Hive.openBox<ReadingSession>('reading_sessions'); // Reading sessions box
  
  // Initialize starred folders repository
  final starredRepo = StarredFoldersRepository();
  await starredRepo.init();
  
  runApp(const MyApp());
}

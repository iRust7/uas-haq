import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/models/user.dart';
import 'data/models/book.dart';
import 'data/repositories/starred_folders_repository.dart';

/// Entry point aplikasi
/// 
/// Initialize Hive dengan 3 boxes dan run MyApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(BookAdapter());
  
  // Open boxes
  await Hive.openBox<User>('user');      // Current session box
  await Hive.openBox<User>('users');     // All registered users box
  await Hive.openBox<Book>('books');     // All books box
  
  // Initialize starred folders repository
  final starredRepo = StarredFoldersRepository();
  await starredRepo.init();
  
  runApp(const MyApp());
}

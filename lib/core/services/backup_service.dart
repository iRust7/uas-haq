import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/reading_session_repository.dart';
import '../../data/repositories/avatar_repository.dart';
import '../../data/repositories/starred_folders_repository.dart';

/// BackupService - Handles backup and restore of user data
/// 
/// Exports all user data (books, sessions, preferences) to JSON
/// and restores data from backup files
class BackupService {
  final _bookRepo = BookRepository();
  final _sessionRepo = ReadingSessionRepository();
  final _avatarRepo = AvatarRepository();
  final _foldersRepo = StarredFoldersRepository();
  
  static const String _backupVersion = '1.0';
  
  /// Export all user data to JSON format
  Future<Map<String, dynamic>> exportBackup() async {
    try {
      // Get all data from repositories
      final books = _bookRepo.getAllBooks();
      final sessions = _sessionRepo.getAllSessions();
      final avatarType = await _avatarRepo.getAvatarType();
      final starredFolders = _foldersRepo.getStarredFolders();
      
      // Create backup structure
      final backup = {
        'version': _backupVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'data': {
          'books': books.map((b) => b.toJson()).toList(),
          'sessions': sessions.map((s) => {
            'id': s.id,
            'bookId': s.bookId,
            'startTime': s.startTime.toIso8601String(),
            'endTime': s.endTime?.toIso8601String(),
            'startPage': s.startPage,
            'endPage': s.endPage,
          }).toList(),
          'preferences': {
            'avatarType': avatarType,
          },
          'starredFolders': starredFolders,
        },
      };
      
      return backup;
    } catch (e) {
      throw Exception('Failed to export backup: $e');
    }
  }
  
  /// Save backup to file
  Future<String?> saveBackupToFile() async {
    try {
      // Export data
      final backupData = await exportBackup();
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      
      // Generate filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = 'backup-folium-$timestamp.flbk';
      
      // Get external storage directory (usually /storage/emulated/0/)
      Directory? directory;
      
      // Try to get Downloads directory first
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download/Folium');
      } else {
        // For other platforms, use app directory
        final appDir = await getExternalStorageDirectory();
        directory = Directory('${appDir!.path}/Folium');
      }
      
      // Create Folium folder if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      final filePath = '${directory.path}/$filename';
      
      // Write to file
      final file = File(filePath);
      await file.writeAsString(jsonString);
      
      return filePath;
    } catch (e) {
      throw Exception('Failed to save backup file: $e');
    }
  }
  
  /// Load backup from file
  Future<Map<String, dynamic>?> loadBackupFromFile() async {
    try {
      // Pick file - use FileType.any because custom extensions not supported on all platforms
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        dialogTitle: 'Select Folium Backup File (.flbk)',
      );
      
      if (result == null || result.files.isEmpty) {
        // User cancelled
        return null;
      }
      
      final filePath = result.files.first.path!;
      
      // Validate file extension
      if (!filePath.toLowerCase().endsWith('.flbk')) {
        throw Exception('Invalid file type. Please select a Folium backup file (.flbk)');
      }
      
      // Read file
      final file = File(filePath);
      final jsonString = await file.readAsString();
      
      // Parse JSON
      final backup = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate backup structure
      if (!backup.containsKey('version') || !backup.containsKey('data')) {
        throw Exception('Invalid backup file structure');
      }
      
      return backup;
    } catch (e) {
      throw Exception('Failed to load backup file: $e');
    }
  }
  
  /// Import backup data (restore)
  Future<bool> importBackup(Map<String, dynamic> backup, {bool mergeData = false}) async {
    try {
      final data = backup['data'] as Map<String, dynamic>;
      
      // Import books
      if (data.containsKey('books')) {
        final booksData = data['books'] as List<dynamic>;
        for (var bookJson in booksData) {
          final book = _bookRepo.fromJson(bookJson as Map<String, dynamic>);
          
          if (mergeData) {
            // Check if book already exists
            final existing = _bookRepo.getBookById(book.id);
            if (existing == null) {
              await _bookRepo.addBook(book);
            }
          } else {
            // Replace existing
            await _bookRepo.addBook(book);
          }
        }
      }
      
      // Import reading sessions
      if (data.containsKey('sessions')) {
        final sessionsData = data['sessions'] as List<dynamic>;
        for (var sessionJson in sessionsData) {
          final json = sessionJson as Map<String, dynamic>;
          final session = _sessionRepo.fromJson({
            'id': json['id'],
            'bookId': json['bookId'],
            'startTime': json['startTime'],
            'endTime': json['endTime'],
            'startPage': json['startPage'],
            'endPage': json['endPage'],
          });
          
          if (mergeData) {
            // Check if session already exists
            final existing = _sessionRepo.getSessionById(session.id);
            if (existing == null) {
              await _sessionRepo.createSession(session);
            }
          } else {
            await _sessionRepo.createSession(session);
          }
        }
      }
      
      // Import preferences
      if (data.containsKey('preferences')) {
        final prefs = data['preferences'] as Map<String, dynamic>;
        if (prefs.containsKey('avatarType')) {
          await _avatarRepo.setAvatarType(prefs['avatarType'] as String);
        }
      }
      
      // Import starred folders
      if (data.containsKey('starredFolders')) {
        final folders = (data['starredFolders'] as List<dynamic>).cast<String>();
        for (var folder in folders) {
          if (mergeData) {
            if (!_foldersRepo.isStarred(folder)) {
              await _foldersRepo.starFolder(folder);
            }
          } else {
            await _foldersRepo.starFolder(folder);
          }
        }
      }
      
      return true;
    } catch (e) {
      throw Exception('Failed to import backup: $e');
    }
  }
  
  /// Restore from backup file
  Future<bool> restoreFromFile({bool mergeData = false}) async {
    try {
      final backup = await loadBackupFromFile();
      if (backup == null) {
        return false; // User cancelled
      }
      
      return await importBackup(backup, mergeData: mergeData);
    } catch (e) {
      throw Exception('Failed to restore from file: $e');
    }
  }
}

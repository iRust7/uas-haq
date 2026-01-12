import 'package:hive/hive.dart';

/// Repository for managing starred/favorite folders
/// 
/// Stores folder paths that user has marked as favorites
class StarredFoldersRepository {
  static const String _boxName = 'starred_folders';
  static const String _starredKey = 'starred_paths';
  
  Box? _box;
  
  /// Initialize Hive box
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }
  
  /// Get all starred folder paths
  List<String> getStarredFolders() {
    if (_box == null) return [];
    final paths = _box!.get(_starredKey, defaultValue: <String>[]);
    return List<String>.from(paths);
  }
  
  /// Check if a folder is starred
  bool isStarred(String folderPath) {
    final starred = getStarredFolders();
    return starred.contains(folderPath);
  }
  
  /// Add folder to starred
  Future<void> starFolder(String folderPath) async {
    final starred = getStarredFolders();
    if (!starred.contains(folderPath)) {
      starred.add(folderPath);
      await _box?.put(_starredKey, starred);
    }
  }
  
  /// Remove folder from starred
  Future<void> unstarFolder(String folderPath) async {
    final starred = getStarredFolders();
    starred.remove(folderPath);
    await _box?.put(_starredKey, starred);
  }
  
  /// Toggle starred status
  Future<void> toggleStar(String folderPath) async {
    if (isStarred(folderPath)) {
      await unstarFolder(folderPath);
    } else {
      await starFolder(folderPath);
    }
  }
  
  /// Clear all starred folders
  Future<void> clearAll() async {
    await _box?.put(_starredKey, <String>[]);
  }
}

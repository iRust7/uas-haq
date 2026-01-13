import 'dart:io';
import 'package:hive/hive.dart';
import '../models/book.dart';

/// BookRepository - Mengelola data buku dengan Hive
/// 
/// Full CRUD operations untuk Book storage
class BookRepository {
  static const String _boxName = 'books';
  
  /// CREATE - Add new book to Hive
  Future<bool> createBook(Book book) async {
    try {
      final box = Hive.box<Book>(_boxName);
      await box.put(book.id, book);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Alias for createBook - used by MyFilesScreen
  Future<bool> addBook(Book book) => createBook(book);
  
  /// READ - Get all books from Hive
  List<Book> getAllBooks() {
    final box = Hive.box<Book>(_boxName);
    return box.values.toList();
  }
  
  /// READ - Get book by ID
  Book? getBookById(String id) {
    final box = Hive.box<Book>(_boxName);
    return box.get(id);
  }
  
  /// UPDATE - Update existing book
  Future<bool> updateBook(Book book) async {
    try {
      final box = Hive.box<Book>(_boxName);
      await box.put(book.id, book);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// DELETE - Remove book from Hive and delete associated PDF file
  Future<bool> deleteBook(String id) async {
    try {
      final box = Hive.box<Book>(_boxName);
      final book = box.get(id);
      
      // Delete associated PDF file if it exists in app storage
      if (book != null && book.filePathOrUri.startsWith('/data')) {
        try {
          final file = File(book.filePathOrUri);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          // Error deleting PDF file, continue with book deletion
          // Continue with book deletion even if file deletion fails
        }
      }
      
      await box.delete(id);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  
  /// Get total books count
  int getBooksCount() {
    final box = Hive.box<Book>(_boxName);
    return box.length;
  }
  
  /// Create Book from JSON (for backup restoration)
  Book fromJson(Map<String, dynamic> json) {
    return Book.fromJson(json);
  }
}

import 'dart:convert';
import 'package:hive/hive.dart';

part 'book.g.dart';

/// Model Book - Entitas utama untuk CRUD buku
/// 
/// Menyimpan informasi buku termasuk metadata,
/// path file PDF, dan progress membaca.
/// 
/// Menggunakan Hive untuk penyimpanan lokal (typeId: 1)
@HiveType(typeId: 1)
class Book extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String author;
  
  @HiveField(3)
  List<String> tags;
  
  @HiveField(4)
  String filePathOrUri;
  
  @HiveField(5)
  DateTime addedAt;
  
  @HiveField(6)
  int lastPage;
  
  @HiveField(7)
  int totalPages;
  
  @HiveField(8)
  List<int> bookmarks;
  
  @HiveField(9)
  DateTime? lastReadAt;
  
  Book({
    required this.id,
    required this.title,
    required this.author,
    this.tags = const [],
    required this.filePathOrUri,
    required this.addedAt,
    this.lastPage = 0,
    this.totalPages = 0,
    this.bookmarks = const [],
    this.lastReadAt,
  });
  
  /// Menghitung progress membaca dalam persen
  double get readingProgress {
    if (totalPages == 0) return 0.0;
    return (lastPage / totalPages) * 100;
  }
  
  /// Mengecek apakah buku sudah selesai dibaca
  bool get isCompleted {
    return totalPages > 0 && lastPage >= totalPages;
  }
  
  /// Convert Book to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'tags': tags,
      'filePathOrUri': filePathOrUri,
      'addedAt': addedAt.toIso8601String(),
      'lastPage': lastPage,
      'totalPages': totalPages,
      'bookmarks': bookmarks,
      'lastReadAt': lastReadAt?.toIso8601String(),
    };
  }
  
  /// Create Book from JSON Map
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      filePathOrUri: json['filePathOrUri'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
      lastPage: json['lastPage'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      bookmarks: (json['bookmarks'] as List<dynamic>?)?.cast<int>() ?? [],
      lastReadAt: json['lastReadAt'] != null 
          ? DateTime.parse(json['lastReadAt'] as String)
          : null,
    );
  }
  
  /// Convert Book to JSON String
  String toJsonString() => jsonEncode(toJson());
  
  /// Create Book from JSON String
  factory Book.fromJsonString(String jsonString) {
    return Book.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
  
  /// Copy with - untuk update buku
  Book copyWith({
    String? id,
    String? title,
    String? author,
    List<String>? tags,
    String? filePathOrUri,
    DateTime? addedAt,
    int? lastPage,
    int? totalPages,
    List<int>? bookmarks,
    DateTime? lastReadAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      tags: tags ?? this.tags,
      filePathOrUri: filePathOrUri ?? this.filePathOrUri,
      addedAt: addedAt ?? this.addedAt,
      lastPage: lastPage ?? this.lastPage,
      totalPages: totalPages ?? this.totalPages,
      bookmarks: bookmarks ?? this.bookmarks,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }
  
  @override
  String toString() {
    return 'Book(id: $id, title: $title, author: $author, lastPage: $lastPage/$totalPages)';
  }
}

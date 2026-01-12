import 'package:hive/hive.dart';

part 'reading_session.g.dart';

/// ReadingSession Model - Tracks individual reading sessions
/// 
/// Stores information about when a user read a book, including
/// start/end times and pages read during the session.
/// 
/// Uses Hive for local storage (typeId: 2)
@HiveType(typeId: 2)
class ReadingSession extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String bookId;
  
  @HiveField(2)
  DateTime startTime;
  
  @HiveField(3)
  DateTime? endTime;
  
  @HiveField(4)
  int startPage;
  
  @HiveField(5)
  int endPage;
  
  ReadingSession({
    required this.id,
    required this.bookId,
    required this.startTime,
    this.endTime,
    required this.startPage,
    this.endPage = 0,
  });
  
  /// Calculate session duration in minutes
  int get durationMinutes {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMinutes;
  }
  
  /// Calculate session duration in seconds
  int get durationSeconds {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inSeconds;
  }
  
  /// Calculate pages read during session
  int get pagesRead {
    if (endPage == 0) return 0;
    return (endPage - startPage).abs() + 1;
  }
  
  /// Check if session is active (not ended)
  bool get isActive {
    return endTime == null;
  }
  
  /// End the session with current time
  void endSession({int? finalPage}) {
    endTime = DateTime.now();
    if (finalPage != null) {
      endPage = finalPage;
    }
  }
  
  @override
  String toString() {
    return 'ReadingSession(id: $id, bookId: $bookId, duration: $durationMinutes min, pages: $pagesRead)';
  }
}

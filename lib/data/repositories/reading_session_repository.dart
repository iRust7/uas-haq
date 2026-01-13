import 'package:hive/hive.dart';
import '../models/reading_session.dart';

/// ReadingSessionRepository - Manages reading sessions with Hive
/// 
/// Full CRUD operations for ReadingSession storage and statistics queries
class ReadingSessionRepository {
  static const String _boxName = 'reading_sessions';
  
  /// CREATE - Add new reading session
  Future<bool> createSession(ReadingSession session) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        return false;
      }
      final box = Hive.box<ReadingSession>(_boxName);
      await box.put(session.id, session);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// READ - Get all reading sessions
  List<ReadingSession> getAllSessions() {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        return [];
      }
      final box = Hive.box<ReadingSession>(_boxName);
      return box.values.toList();
    } catch (e) {
      return [];
    }
  }
  
  /// READ - Get session by ID
  ReadingSession? getSessionById(String id) {
    final box = Hive.box<ReadingSession>(_boxName);
    return box.get(id);
  }
  
  /// READ - Get sessions for a specific book
  List<ReadingSession> getSessionsByBook(String bookId) {
    final box = Hive.box<ReadingSession>(_boxName);
    return box.values.where((s) => s.bookId == bookId).toList();
  }
  
  /// READ - Get sessions within a date range
  List<ReadingSession> getSessionsByDateRange(DateTime start, DateTime end) {
    final box = Hive.box<ReadingSession>(_boxName);
    return box.values.where((s) {
      final sessionDate = s.startTime;
      return sessionDate.isAfter(start) && sessionDate.isBefore(end);
    }).toList();
  }
  
  /// READ - Get today's sessions
  List<ReadingSession> getTodaySessions() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getSessionsByDateRange(startOfDay, endOfDay);
  }
  
  /// READ - Get this week's sessions
  List<ReadingSession> getWeekSessions() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return getSessionsByDateRange(startDate, now);
  }
  
  /// READ - Get this month's sessions
  List<ReadingSession> getMonthSessions() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return getSessionsByDateRange(startOfMonth, now);
  }
  
  /// READ - Get active (not ended) session
  ReadingSession? getActiveSession() {
    final box = Hive.box<ReadingSession>(_boxName);
    try {
      return box.values.firstWhere((s) => s.isActive);
    } catch (e) {
      return null;
    }
  }
  
  /// UPDATE - Update existing session
  Future<bool> updateSession(ReadingSession session) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        return false;
      }
      final box = Hive.box<ReadingSession>(_boxName);
      await box.put(session.id, session);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// DELETE - Remove session
  Future<bool> deleteSession(String id) async {
    try {
      final box = Hive.box<ReadingSession>(_boxName);
      await box.delete(id);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// STATISTICS - Get total reading time in minutes
  int getTotalReadingMinutes() {
    final sessions = getAllSessions();
    return sessions.fold(0, (sum, s) => sum + s.durationMinutes);
  }
  
  /// STATISTICS - Get total pages read
  int getTotalPagesRead() {
    final sessions = getAllSessions();
    return sessions.fold(0, (sum, s) => sum + s.pagesRead);
  }
  
  /// STATISTICS - Get reading streak (consecutive days with reading)
  int getReadingStreak() {
    final sessions = getAllSessions();
    if (sessions.isEmpty) return 0;
    
    // Sort sessions by date (most recent first)
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    
    // Get unique reading dates
    final readingDates = <DateTime>{};
    for (var session in sessions) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      readingDates.add(date);
    }
    
    // Calculate consecutive days
    final sortedDates = readingDates.toList()..sort((a, b) => b.compareTo(a));
    
    int streak = 0;
    DateTime? expectedDate;
    
    for (var date in sortedDates) {
      if (expectedDate == null) {
        // First date
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        
        // Streak only counts if reading happened today or yesterday
        if (date == todayDate || date == todayDate.subtract(const Duration(days: 1))) {
          streak = 1;
          expectedDate = date.subtract(const Duration(days: 1));
        } else {
          break;
        }
      } else {
        // Check if this date is consecutive
        if (date == expectedDate) {
          streak++;
          expectedDate = date.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }
    
    return streak;
  }
  
  /// STATISTICS - Get average session duration in minutes
  double getAverageSessionMinutes() {
    final sessions = getAllSessions().where((s) => s.endTime != null).toList();
    if (sessions.isEmpty) return 0.0;
    
    final totalMinutes = sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    return totalMinutes / sessions.length;
  }
  
  /// Create ReadingSession from JSON (for backup restoration)
  ReadingSession fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String)
          : null,
      startPage: json['startPage'] as int,
      endPage: json['endPage'] as int? ?? 0,
    );
  }
}

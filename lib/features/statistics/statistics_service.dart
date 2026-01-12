import '../../data/repositories/reading_session_repository.dart';
import '../../data/repositories/book_repository.dart';

/// StatisticsService - Calculate various reading statistics
/// 
/// Provides methods to calculate aggregate statistics from reading sessions
class StatisticsService {
  final _sessionRepo = ReadingSessionRepository();
  final _bookRepo = BookRepository();
  
  /// Get total reading time across all sessions (in minutes)
  int getTotalReadingMinutes() {
    return _sessionRepo.getTotalReadingMinutes();
  }
  
  /// Get total reading time formatted as string (e.g., "2h 30m")
  String getTotalReadingTimeFormatted() {
    final minutes = getTotalReadingMinutes();
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours == 0) {
      return '${mins}m';
    } else if (mins == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${mins}m';
    }
  }
  
  /// Get total unique pages read across all sessions
  int getTotalPagesRead() {
    return _sessionRepo.getTotalPagesRead();
  }
  
  /// Get current reading streak (consecutive days with reading)
  int getReadingStreak() {
    return _sessionRepo.getReadingStreak();
  }
  
  /// Get average session duration in minutes
  double getAverageSessionMinutes() {
    return _sessionRepo.getAverageSessionMinutes();
  }
  
  /// Get today's reading statistics
  Map<String, dynamic> getTodayStatistics() {
    final sessions = _sessionRepo.getTodaySessions();
    
    final totalMinutes = sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    final totalPages = sessions.fold(0, (sum, s) => sum + s.pagesRead);
    final sessionCount = sessions.length;
    
    return {
      'totalMinutes': totalMinutes,
      'totalPages': totalPages,
      'sessionCount': sessionCount,
      'sessions': sessions,
    };
  }
  
  /// Get this week's reading statistics
  Map<String, dynamic> getWeeklyStatistics() {
    final sessions = _sessionRepo.getWeekSessions();
    
    final totalMinutes = sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    final totalPages = sessions.fold(0, (sum, s) => sum + s.pagesRead);
    final sessionCount = sessions.length;
    
    // Group by day
    final dailyStats = <DateTime, Map<String, int>>{};
    for (var session in sessions) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      
      if (!dailyStats.containsKey(date)) {
        dailyStats[date] = {'minutes': 0, 'pages': 0, 'sessions': 0};
      }
      
      dailyStats[date]!['minutes'] = dailyStats[date]!['minutes']! + session.durationMinutes;
      dailyStats[date]!['pages'] = dailyStats[date]!['pages']! + session.pagesRead;
      dailyStats[date]!['sessions'] = dailyStats[date]!['sessions']! + 1;
    }
    
    return {
      'totalMinutes': totalMinutes,
      'totalPages': totalPages,
      'sessionCount': sessionCount,
      'sessions': sessions,
      'dailyStats': dailyStats,
    };
  }
  
  /// Get this month's reading statistics
  Map<String, dynamic> getMonthlyStatistics() {
    final sessions = _sessionRepo.getMonthSessions();
    
    final totalMinutes = sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    final totalPages = sessions.fold(0, (sum, s) => sum + s.pagesRead);
    final sessionCount = sessions.length;
    
    return {
      'totalMinutes': totalMinutes,
      'totalPages': totalPages,
      'sessionCount': sessionCount,
      'sessions': sessions,
    };
  }
  
  /// Get statistics for a specific book
  Map<String, dynamic> getBookStatistics(String bookId) {
    final sessions = _sessionRepo.getSessionsByBook(bookId);
    
    final totalMinutes = sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    final totalPages = sessions.fold(0, (sum, s) => sum + s.pagesRead);
    final sessionCount = sessions.length;
    
    return {
      'totalMinutes': totalMinutes,
      'totalPages': totalPages,
      'sessionCount': sessionCount,
      'sessions': sessions,
    };
  }
  
  /// Get top books by reading time
  List<Map<String, dynamic>> getTopBooksByTime({int limit = 5}) {
    final allBooks = _bookRepo.getAllBooks();
    final bookStats = <Map<String, dynamic>>[];
    
    for (var book in allBooks) {
      final stats = getBookStatistics(book.id);
      if (stats['totalMinutes'] > 0) {
        bookStats.add({
          'book': book,
          'totalMinutes': stats['totalMinutes'],
          'totalPages': stats['totalPages'],
          'sessionCount': stats['sessionCount'],
        });
      }
    }
    
    // Sort by total minutes
    bookStats.sort((a, b) => (b['totalMinutes'] as int).compareTo(a['totalMinutes'] as int));
    
    return bookStats.take(limit).toList();
  }
  
  /// Get top books by pages read
  List<Map<String, dynamic>> getTopBooksByPages({int limit = 5}) {
    final allBooks = _bookRepo.getAllBooks();
    final bookStats = <Map<String, dynamic>>[];
    
    for (var book in allBooks) {
      final stats = getBookStatistics(book.id);
      if (stats['totalPages'] > 0) {
        bookStats.add({
          'book': book,
          'totalMinutes': stats['totalMinutes'],
          'totalPages': stats['totalPages'],
          'sessionCount': stats['sessionCount'],
        });
      }
    }
    
    // Sort by total pages
    bookStats.sort((a, b) => (b['totalPages'] as int).compareTo(a['totalPages'] as int));
    
    return bookStats.take(limit).toList();
  }
  
  /// Get recent reading sessions
  List<dynamic> getRecentSessions({int limit = 10}) {
    final sessions = _sessionRepo.getAllSessions();
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions.take(limit).toList();
  }
}

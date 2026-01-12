import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/book.dart';
import 'statistics_service.dart';

/// DetailedStatisticsScreen - Full screen with comprehensive reading statistics
/// 
/// Shows detailed breakdown of reading metrics, charts, and history
class DetailedStatisticsScreen extends StatefulWidget {
  const DetailedStatisticsScreen({super.key});

  @override
  State<DetailedStatisticsScreen> createState() => _DetailedStatisticsScreenState();
}

class _DetailedStatisticsScreenState extends State<DetailedStatisticsScreen> {
  final _statsService = StatisticsService();
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final totalMinutes = _statsService.getTotalReadingMinutes();
    final totalTimeFormatted = _statsService.getTotalReadingTimeFormatted();
    final totalPages = _statsService.getTotalPagesRead();
    final streak = _statsService.getReadingStreak();
    final avgSession = _statsService.getAverageSessionMinutes();
    
    final todayStats = _statsService.getTodayStatistics();
    final weeklyStats = _statsService.getWeeklyStatistics();
    final monthlyStats = _statsService.getMonthlyStatistics();
    
    final topBooksByTime = _statsService.getTopBooksByTime(limit: 5);
    final recentSessions = _statsService.getRecentSessions(limit: 10);
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          'READING STATISTICS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Section
            _buildSectionHeader('OVERVIEW', isDark),
            const SizedBox(height: 16),
            _buildOverviewCards(
              totalTimeFormatted: totalTimeFormatted,
              totalPages: totalPages,
              streak: streak,
              avgSession: avgSession,
              isDark: isDark,
            ),
            const SizedBox(height: 32),
            
            // Today Section
            _buildSectionHeader('TODAY', isDark),
            const SizedBox(height: 16),
            _buildTodayCard(todayStats, isDark),
            const SizedBox(height: 32),
            
            // This Week Section
            _buildSectionHeader('THIS WEEK', isDark),
            const SizedBox(height: 16),
            _buildWeekCard(weeklyStats, isDark),
            const SizedBox(height: 32),
            
            // This Month Section
            _buildSectionHeader('THIS MONTH', isDark),
            const SizedBox(height: 16),
            _buildMonthCard(monthlyStats, isDark),
            const SizedBox(height: 32),
            
            // Top Books Section
            if (topBooksByTime.isNotEmpty) ...[ 
              _buildSectionHeader('TOP BOOKS BY TIME', isDark),
              const SizedBox(height: 16),
              _buildTopBooksList(topBooksByTime, isDark),
              const SizedBox(height: 32),
            ],
            
            // Recent Sessions Section
            if (recentSessions.isNotEmpty) ...[
              _buildSectionHeader('RECENT SESSIONS', isDark),
              const SizedBox(height: 16),
              _buildRecentSessionsList(recentSessions, isDark),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
  
  Widget _buildOverviewCards({
    required String totalTimeFormatted,
    required int totalPages,
    required int streak,
    required double avgSession,
    required bool isDark,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.schedule,
                label: 'Total Time',
                value: totalTimeFormatted,
                color: Colors.blue,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.article,
                label: 'Total Pages',
                value: totalPages.toString(),
                color: Colors.green,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                label: 'Current Streak',
                value: '$streak days',
                color: Colors.orange,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.timer_outlined,
                label: 'Avg Session',
                value: '${avgSession.toStringAsFixed(0)}m',
                color: Colors.purple,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTodayCard(Map<String, dynamic> stats, bool isDark) {
    final totalMinutes = stats['totalMinutes'] as int;
    final totalPages = stats['totalPages'] as int;
    final sessionCount = stats['sessionCount'] as int;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildStatRow('Reading Time', '${totalMinutes}m', Colors.blue, isDark),
          const SizedBox(height: 12),
          _buildStatRow('Pages Read', totalPages.toString(), Colors.green, isDark),
          const SizedBox(height: 12),
          _buildStatRow('Sessions', sessionCount.toString(), Colors.purple, isDark),
        ],
      ),
    );
  }
  
  Widget _buildWeekCard(Map<String, dynamic> stats, bool isDark) {
    final totalMinutes = stats['totalMinutes'] as int;
    final totalPages = stats['totalPages'] as int;
    final sessionCount = stats['sessionCount'] as int;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildStatRow('Reading Time', '${totalMinutes}m', Colors.blue, isDark),
          const SizedBox(height: 12),
          _buildStatRow('Pages Read', totalPages.toString(), Colors.green, isDark),
          const SizedBox(height: 12),
          _buildStatRow('Sessions', sessionCount.toString(), Colors.purple, isDark),
        ],
      ),
    );
  }
  
  Widget _buildMonthCard(Map<String, dynamic> stats, bool isDark) {
    final totalMinutes = stats['totalMinutes'] as int;
    final totalPages = stats['totalPages'] as int;
    final sessionCount = stats['sessionCount'] as int;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildStatRow('Reading Time', '${totalMinutes}m', Colors.blue, isDark),
          const SizedBox(height: 12),
          _buildStatRow('Pages Read', totalPages.toString(), Colors.green, isDark),
          const SizedBox(height: 12),
          _buildStatRow('Sessions', sessionCount.toString(), Colors.purple, isDark),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value, Color color, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTopBooksList(List<Map<String, dynamic>> books, bool isDark) {
    return Column(
      children: books.map((bookData) {
        final book = bookData['book'] as Book;
        final minutes = bookData['totalMinutes'] as int;
        final hours = minutes ~/ 60;
        final mins = minutes % 60;
        final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.book, color: Colors.blue[400], size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.blue[400],
                    ),
                  ),
                  Text(
                    '${bookData['totalPages']} pages',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildRecentSessionsList(List<dynamic> sessions, bool isDark) {
    return Column(
      children: sessions.map((session) {
        final dateFormat = DateFormat('MMM dd, yyyy');
        final timeFormat = DateFormat('HH:mm');
        
        final startTime = session.startTime as DateTime;
        final duration = session.durationMinutes as int;
        final pages = session.pagesRead as int;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(startTime),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    timeFormat.format(startTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.blue[400]),
                  const SizedBox(width: 4),
                  Text(
                    '${duration}m',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.article, size: 16, color: Colors.green[400]),
                  const SizedBox(width: 4),
                  Text(
                    '$pages pages',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

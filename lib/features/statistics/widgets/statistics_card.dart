import 'package:flutter/material.dart';
import '../statistics_service.dart';
import '../detailed_statistics_screen.dart';

/// StatisticsCard - Summary widget for home screen
/// 
/// Displays key reading statistics in a tappable card
/// that navigates to detailed statistics screen
class StatisticsCard extends StatefulWidget {
  const StatisticsCard({super.key});

  @override
  State<StatisticsCard> createState() => _StatisticsCardState();
}

class _StatisticsCardState extends State<StatisticsCard> {
  final _statsService = StatisticsService();
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Safely get statistics with fallback values
    int totalMinutes = 0;
    String totalTimeFormatted = '0m';
    int totalPages = 0;
    int streak = 0;
    Map<String, dynamic> todayStats = {'totalMinutes': 0, 'totalPages': 0, 'sessionCount': 0};
    
    try {
      totalMinutes = _statsService.getTotalReadingMinutes();
      totalTimeFormatted = _statsService.getTotalReadingTimeFormatted();
      totalPages = _statsService.getTotalPagesRead();
      streak = _statsService.getReadingStreak();
      todayStats = _statsService.getTodayStatistics();
    } catch (e) {
      // Box not ready yet, use default values
      debugPrint('Statistics not available yet: $e');
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DetailedStatisticsScreen(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 28,
                        color: Colors.purple[400],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'READING STATS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Stats Grid
              Row(
                children: [
                  // Total Time
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.schedule,
                      label: 'Total Time',
                      value: totalMinutes == 0 ? '0m' : totalTimeFormatted,
                      color: Colors.blue,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Total Pages
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.article,
                      label: 'Pages Read',
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
                  // Streak
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.local_fire_department,
                      label: 'Streak',
                      value: '$streak days',
                      color: Colors.orange,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Today
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.today,
                      label: 'Today',
                      value: '${todayStats['totalMinutes']}m',
                      color: Colors.purple,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              
              // Tap to see more hint
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Tap to see detailed statistics',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white38 : Colors.black38,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/book.dart';
import '../../data/repositories/book_repository.dart';
import '../../core/widgets/pdf_thumbnail_widget.dart';
import '../book_form/book_form_screen.dart';
import '../reader/reader_screen.dart';
import '../statistics/statistics_service.dart';

/// BookDetailScreen - Modern detailed book view
/// 
/// Features:
/// - Hero header with PDF thumbnail
/// - Bold typography and visual hierarchy
/// - Modern progress indicators
/// - Reading statistics integration
/// - Enhanced bookmarks section
/// - Modern action buttons
class BookDetailScreen extends StatefulWidget {
  final Book book;
  
  const BookDetailScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Book _currentBook;
  final _bookRepository = BookRepository();
  final _statsService = StatisticsService();

  @override
  void initState() {
    super.initState();
    _currentBook = widget.book;
  }

  /// Refresh book data from Hive
  Future<void> _refreshBook() async {
    final updatedBook = _bookRepository.getBookById(widget.book.id);
    if (updatedBook != null && mounted) {
      setState(() {
        _currentBook = updatedBook;
      });
    }
  }

  /// Handle continue reading - Navigate to ReaderScreen
  Future<void> _handleContinueReading(BuildContext context) async {
    // Check if file path is placeholder
    if (_currentBook.filePathOrUri.isEmpty || _currentBook.filePathOrUri.startsWith('/storage')) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File PDF belum tersedia. Import PDF terlebih dahulu.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    // Check if file exists
    final file = File(_currentBook.filePathOrUri);
    if (!await file.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File PDF tidak ditemukan'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Navigate to Reader
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderScreen(book: _currentBook),
      ),
    );
    
    // Refresh book data after reading
    await _refreshBook();
  }

  /// Handle edit - Navigate to BookFormScreen
  Future<void> _handleEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookFormScreen(book: _currentBook),
      ),
    );
    
    // Jika edit berhasil, refresh dan pop kembali ke Library
    if (result == true && context.mounted) {
      await _refreshBook();
      if (context.mounted) {
        Navigator.pop(context, true); // Pop ke Library dengan result
      }
    }
  }

  /// Handle share - Share via WhatsApp or Email
  Future<void> _handleShare(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bagikan Buku'),
        content: const Text('Pilih platform untuk berbagi'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _shareViaWhatsApp();
            },
            icon: const Icon(Icons.chat, color: Colors.green),
            label: const Text('WhatsApp'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _shareViaEmail();
            },
            icon: const Icon(Icons.email, color: Colors.blue),
            label: const Text('Email'),
          ),
        ],
      ),
    );
  }

  /// Share via WhatsApp
  Future<void> _shareViaWhatsApp() async {
    final message = _buildShareMessage();
    final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(message)}';
    
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp tidak tersedia')),
        );
      }
    }
  }

  /// Share via Email
  Future<void> _shareViaEmail() async {
    final subject = 'Book Recommendation: ${_currentBook.title}';
    final body = _buildShareMessage();
    final emailUrl = 'mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
    
    if (await canLaunchUrl(Uri.parse(emailUrl))) {
      await launchUrl(Uri.parse(emailUrl));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email client tidak tersedia')),
        );
      }
    }
  }

  /// Build share message text
  String _buildShareMessage() {
    final progress = _currentBook.readingProgress.toStringAsFixed(1);
    final statusText = _currentBook.isCompleted ? 'Selesai dibaca!' : 'Progress: $progress%';
    
    return '''
Sedang baca: ${_currentBook.title}
Penulis: ${_currentBook.author}
$statusText
Halaman: ${_currentBook.lastPage} dari ${_currentBook.totalPages}

Bagikan dari Offline Book Library
''';
  }

  /// Handle jump to bookmark page
  Future<void> _handleJumpToBookmark(BuildContext context, int page) async {
    // Check if file path is placeholder
    if (_currentBook.filePathOrUri.isEmpty || _currentBook.filePathOrUri.startsWith('/storage')) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File PDF belum tersedia. Import PDF terlebih dahulu.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    // Check if file exists
    final file = File(_currentBook.filePathOrUri);
    if (!await file.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File PDF tidak ditemukan'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Update lastPage to bookmark page and navigate
    final updatedBook = _currentBook.copyWith(lastPage: page);
    await _bookRepository.updateBook(updatedBook);
    
    // Navigate to Reader (will open at that page)
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderScreen(book: updatedBook),
      ),
    );
    
    // Refresh book data after reading
    await _refreshBook();
  }

  /// Handle delete - Actually delete from Hive
  Future<void> _handleDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Buku'),
        content: Text('Apakah Anda yakin ingin menghapus "${_currentBook.title}"?\n\nData buku akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    
    if (confirm == true && context.mounted) {
      final success = await _bookRepository.deleteBook(_currentBook.id);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Buku "${_currentBook.title}" berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop ke Library dengan result true
        Navigator.pop(context, true);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus buku'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          'BOOK DETAILS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Header Section
            _buildHeroHeader(isDark),
            const SizedBox(height: 32),
            
            // Progress Section
            _buildProgressSection(isDark),
            const SizedBox(height: 24),
            
            // Statistics Section
            _buildStatisticsSection(isDark),
            const SizedBox(height: 24),
            
            // Bookmarks Section
            _buildBookmarksSection(isDark),
            const SizedBox(height: 32),
            
            // Actions Section
            _buildActionsSection(isDark),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Build hero header with PDF thumbnail
  Widget _buildHeroHeader(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PDF Thumbnail
        Container(
          width: 120,
          height: 168,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PdfThumbnailWidget(
              pdfPath: _currentBook.filePathOrUri,
              bookId: _currentBook.id,
              width: 120,
              height: 168,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 20),
        
        // Book Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                _currentBook.title.toUpperCase(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : Colors.black,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              
              // Author
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _currentBook.author,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Completion Badge
              if (_currentBook.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'COMPLETED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              
              // Tags
              if (_currentBook.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _currentBook.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue[400]!,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue[400],
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build modern progress section
  Widget _buildProgressSection(bool isDark) {
    final progress = _currentBook.readingProgress;
    final isCompleted = _currentBook.isCompleted;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            'READING PROGRESS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Circular Progress
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: progress / 100,
                        strokeWidth: 10,
                        backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                        color: isCompleted ? Colors.green[600] : Colors.blue[600],
                      ),
                    ),
                    Text(
                      '${progress.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Pages Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_currentBook.lastPage}',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.blue[600],
                      height: 1,
                    ),
                  ),
                  Text(
                    'of ${_currentBook.totalPages}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PAGES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 8,
              backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
              color: isCompleted ? Colors.green[600] : Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Build statistics section
  Widget _buildStatisticsSection(bool isDark) {
    Map<String, dynamic> bookStats = {
      'totalMinutes': 0,
      'sessionCount': 0,
    };
    
    try {
      bookStats = _statsService.getBookStatistics(_currentBook.id);
    } catch (e) {
      // Stats not available yet
    }
    
    final totalMinutes = bookStats['totalMinutes'] as int;
    final sessionCount = bookStats['sessionCount'] as int;
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
    
    if (totalMinutes == 0) {
      return const SizedBox.shrink();
    }
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'READING STATS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.schedule,
                  label: 'Time Spent',
                  value: timeStr,
                  color: Colors.purple,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.auto_stories,
                  label: 'Sessions',
                  value: sessionCount.toString(),
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
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

  /// Build bookmarks section with grid layout
  Widget _buildBookmarksSection(bool isDark) {
    final hasBookmarks = _currentBook.bookmarks.isNotEmpty;
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BOOKMARKS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentBook.bookmarks.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Bookmarks Grid or Empty State
          if (hasBookmarks)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemCount: _currentBook.bookmarks.length,
              itemBuilder: (context, index) {
                final page = _currentBook.bookmarks[index];
                return GestureDetector(
                  onTap: () => _handleJumpToBookmark(context, page),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark,
                          size: 20,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          page.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          'PAGE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 48,
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No bookmarks yet',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build modern actions section
  Widget _buildActionsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary Action: Continue Reading - HUGE Button
        Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => _handleContinueReading(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow, size: 28),
                const SizedBox(width: 12),
                Text(
                  _currentBook.lastPage > 0 ? 'CONTINUE READING' : 'START READING',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Secondary Actions Row
        Row(
          children: [
            // Edit
            Expanded(
              child: _buildSecondaryAction(
                icon: Icons.edit,
                label: 'EDIT',
                color: Colors.purple,
                onPressed: () => _handleEdit(context),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            
            // Share
            Expanded(
              child: _buildSecondaryAction(
                icon: Icons.share,
                label: 'SHARE',
                color: Colors.green,
                onPressed: () => _handleShare(context),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            
            // Delete
            Expanded(
              child: _buildSecondaryAction(
                icon: Icons.delete,
                label: 'DELETE',
                color: Colors.red,
                onPressed: () => _handleDelete(context),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

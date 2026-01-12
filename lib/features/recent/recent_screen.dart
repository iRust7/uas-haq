import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/book.dart';
import '../../data/repositories/book_repository.dart';
import '../book_detail/book_detail_screen.dart';
import '../shelf/widgets/book_card.dart';

/// RecentScreen - Recently read books
/// 
/// Shows books sorted by access time (using addedAt as placeholder)
/// TODO: Use lastReadAt when field is added in R2.10
class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  final _bookRepository = BookRepository();
  List<Book> _recentBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentBooks();
  }

  Future<void> _loadRecentBooks() async {
    setState(() => _isLoading = true);
    
    try {
      // Get all books and filter to those that have been read (lastReadAt is set)
      final allBooks = _bookRepository.getAllBooks();
      _recentBooks = allBooks
          .where((book) => book.lastReadAt != null)
          .toList()
        ..sort((a, b) => b.lastReadAt!.compareTo(a.lastReadAt!)); // Most recent first
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading books: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleBookTap(Book book) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(book: book),
      ),
    );
    
    // Refresh if book was modified
    if (result == true) {
      _loadRecentBooks();
    }
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu lalu';
    } else {
      return DateFormat('d MMM yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recentBooks.isEmpty
              ? _buildEmptyState()
              : _buildRecentList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Recent Books',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start reading to see your recent books here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentList() {
    return RefreshIndicator(
      onRefresh: _loadRecentBooks,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _recentBooks.length,
        itemBuilder: (context, index) {
          final book = _recentBooks[index];
          return Column(
            children: [
              BookCard(
                book: book,
                onTap: () => _handleBookTap(book),
              ),
              // Time indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Last accessed: ${_getRelativeTime(book.lastReadAt ?? book.addedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

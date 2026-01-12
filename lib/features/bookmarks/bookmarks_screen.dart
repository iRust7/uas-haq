import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../data/models/book.dart';
import '../../data/repositories/book_repository.dart';
import '../book_detail/book_detail_screen.dart';
import '../reader/reader_screen.dart';
import 'dart:io';

/// BookmarksScreen - Bold Modern Design
/// 
/// Features:
/// - LARGE bold typography
/// - Clean modern cards
/// - Pill-shaped chips
/// - High contrast design
class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final _bookRepository = BookRepository();
  List<Book> _booksWithBookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    
    try {
      final allBooks = _bookRepository.getAllBooks();
      _booksWithBookmarks = allBooks
          .where((book) => book.bookmarks.isNotEmpty)
          .toList()
        ..sort((a, b) => b.bookmarks.length.compareTo(a.bookmarks.length));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bookmarks: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleJumpToBookmark(Book book, int page) async {
    if (book.filePathOrUri.isEmpty || book.filePathOrUri.startsWith('/storage')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF file not available'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    final file = File(book.filePathOrUri);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF file not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final updatedBook = book.copyWith(lastPage: page);
    await _bookRepository.updateBook(updatedBook);
    
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReaderScreen(book: updatedBook),
        ),
      );
      _loadBookmarks();
    }
  }

  void _handleBookTap(Book book) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(book: book),
      ),
    );
    
    if (result == true) {
      _loadBookmarks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalBookmarks = _booksWithBookmarks.fold<int>(0, (sum, b) => sum + b.bookmarks.length);
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: CustomScrollView(
        slivers: [
          // Bold App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: isDark ? Colors.black : Colors.white,
            elevation: 0,
            title: Text(
              'BOOKMARKS',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          
          // Stats Header
          if (_booksWithBookmarks.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('BOOKS', _booksWithBookmarks.length, Colors.blue, isDark),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                      ),
                      _buildStatItem('MARKERS', totalBookmarks, Colors.amber, isDark),
                    ],
                  ),
                ),
              ),
            ),
          
          // Content
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _booksWithBookmarks.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState())
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildBookmarkCard(_booksWithBookmarks[index], isDark),
                          childCount: _booksWithBookmarks.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarkCard(Book book, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Book Header
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.bookmark, color: Colors.amber[700], size: 24),
            ),
            title: Text(
              book.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                book.author,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.black45,
                ),
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              onPressed: () => _handleBookTap(book),
              tooltip: 'View book',
            ),
          ),
          
          // Bookmark Chips
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: book.bookmarks.map((page) {
                return InkWell(
                  onTap: () => _handleJumpToBookmark(book, page),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.amber[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bookmark, size: 14, color: Colors.black),
                        const SizedBox(width: 6),
                        Text(
                          'Page $page',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/bookmarkpage.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 24),
            Text(
              'No Bookmarks Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bookmark pages while reading\nto quick access them here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

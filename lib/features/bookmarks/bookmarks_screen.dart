import 'package:flutter/material.dart';
import '../../data/models/book.dart';
import '../../data/repositories/book_repository.dart';
import '../book_detail/book_detail_screen.dart';
import '../reader/reader_screen.dart';
import 'dart:io';

/// BookmarksScreen - All bookmarks grouped by book
/// 
/// Shows ExpansionTiles per book with bookmark pages as chips
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
    // Check file validity
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

    // Update lastPage and navigate to reader
    final updatedBook = book.copyWith(lastPage: page);
    await _bookRepository.updateBook(updatedBook);
    
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReaderScreen(book: updatedBook),
        ),
      );
      
      // Refresh after reading
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          if (_booksWithBookmarks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '${_booksWithBookmarks.fold<int>(0, (sum, b) => sum + b.bookmarks.length)} total',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _booksWithBookmarks.isEmpty
              ? _buildEmptyState()
              : _buildBookmarksList(),
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
              Icons.bookmark_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Bookmarks Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookmark pages while reading to quick access them here',
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

  Widget _buildBookmarksList() {
    return RefreshIndicator(
      onRefresh: _loadBookmarks,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _booksWithBookmarks.length,
        itemBuilder: (context, index) {
          final book = _booksWithBookmarks[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ExpansionTile(
              leading: Icon(
                Icons.bookmark,
                color: Colors.amber,
              ),
              title: Text(
                book.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${book.author} • ${book.bookmarks.length} bookmark${book.bookmarks.length > 1 ? 's' : ''}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _handleBookTap(book),
                tooltip: 'View book details',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: book.bookmarks.map((page) {
                      return ActionChip(
                        avatar: const Icon(Icons.bookmark, size: 16),
                        label: Text('Page $page'),
                        onPressed: () => _handleJumpToBookmark(book, page),
                        backgroundColor: Colors.amber,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

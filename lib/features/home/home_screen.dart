import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:lottie/lottie.dart';
import '../../data/models/book.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/starred_folders_repository.dart';
import '../../core/widgets/enhanced_widgets.dart';
import '../../core/widgets/pdf_thumbnail_widget.dart';
import '../book_detail/book_detail_screen.dart';
import '../files/my_files_screen.dart';

/// Home Screen - Bold Magazine Layout
/// 
/// Features:
/// - LARGE bold typography (42px headers)
/// - High contrast design
/// - Magazine-style asymmetric layout
/// - Clean cards with borders (no shadows)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _bookRepository = BookRepository();
  final _starredRepo = StarredFoldersRepository();
  List<Book> _allBooks = [];
  List<String> _starredFolders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStarredRepo();
    _loadBooks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload data when app comes to foreground or resumes
    if (state == AppLifecycleState.resumed) {
      _loadBooks();
    }
  }

  Future<void> _initStarredRepo() async {
    await _starredRepo.init();
    if (mounted) {
      setState(() {
        _starredFolders = _starredRepo.getStarredFolders();
      });
    }
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    
    try {
      _allBooks = _bookRepository.getAllBooks();
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

  // Statistics
  int get _totalBooks => _allBooks.length;
  int get _inProgressBooks => _allBooks.where((b) => b.lastPage > 0 && !b.isCompleted).length;
  int get _completedBooks => _allBooks.where((b) => b.isCompleted).length;

  List<Book> get _recentBooks {
    final books = _allBooks.where((b) => b.lastReadAt != null).toList();
    books.sort((a, b) => b.lastReadAt!.compareTo(a.lastReadAt!));
    return books.take(5).toList();
  }

  List<Book> get _bookmarkedBooks {
    final books = _allBooks.where((b) => b.bookmarks.isNotEmpty).toList();
    books.sort((a, b) => b.bookmarks.length.compareTo(a.bookmarks.length));
    return books.take(6).toList();
  }

  void _handleBookTap(Book book) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(book: book),
      ),
    );
    // Reload setelah kembali dari detail screen
    _loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBooks,
              child: CustomScrollView(
                slivers: [
                  // Bold App Bar
                  SliverAppBar(
                    floating: true,
                    backgroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          'assets/animations/home.json',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'LIBRARY',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Stats Pills
                        _buildStatsPills(),
                        const SizedBox(height: 32),
                        
                        // Starred Folders
                        if (_starredFolders.isNotEmpty) ...[
                          _buildSectionHeader('QUICK ACCESS'),
                          const SizedBox(height: 16),
                          _buildStarredFolders(),
                          const SizedBox(height: 32),
                        ],
                        
                        // Recent Books
                        if (_recentBooks.isNotEmpty) ...[
                          _buildSectionHeader('CONTINUE READING'),
                          const SizedBox(height: 16),
                          _buildRecentBooks(),
                          const SizedBox(height: 32),
                        ],
                        
                        // Bookmarked Books
                        if (_bookmarkedBooks.isNotEmpty) ...[
                          _buildSectionHeader('BOOKMARKED'),
                          const SizedBox(height: 16),
                          _buildBookmarksGrid(),
                        ],
                        
                        // Empty state
                        if (_allBooks.isEmpty) _buildEmptyState(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildStatsPills() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Expanded(child: _buildStatPill('TOTAL', _totalBooks, Colors.blue, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatPill('READING', _inProgressBooks, Colors.orange, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatPill('DONE', _completedBooks, Colors.green, isDark)),
      ],
    );
  }

  Widget _buildStatPill(String label, int count, Color accentColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: accentColor,
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
      ),
    );
  }

  Widget _buildStarredFolders() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _starredFolders.length,
        itemBuilder: (context, index) {
          final folderPath = _starredFolders[index];
          final folderName = path.basename(folderPath);
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyFilesScreen(initialPath: folderPath),
                ),
              ).then((_) => _initStarredRepo());
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder, size: 32, color: Colors.amber[700]),
                  const SizedBox(height: 8),
                  Text(
                    folderName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentBooks() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recentBooks.length,
        itemBuilder: (context, index) {
          final book = _recentBooks[index];
          
          return GestureDetector(
            onTap: () => _handleBookTap(book),
            child: Container(
              width: 300,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(20),
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
                    Row(
                      children: [
                        // PDF thumbnail instead of icon
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 48,
                            height: 64,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: PdfThumbnailWidget(
                              pdfPath: book.filePathOrUri,
                              bookId: book.id,
                              width: 48,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.author,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white60 : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Progress
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: book.readingProgress / 100,
                        backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                        valueColor: AlwaysStoppedAnimation(Colors.blue[700]),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${book.readingProgress.toStringAsFixed(0)}% complete',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookmarksGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _bookmarkedBooks.length,
      itemBuilder: (context, index) {
        final book = _bookmarkedBooks[index];
        
        return GestureDetector(
          onTap: () => _handleBookTap(book),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PDF Thumbnail for bookmarked books
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: PdfThumbnailWidget(
                        pdfPath: book.filePathOrUri,
                        bookId: book.id,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bookmark, size: 14, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          '${book.bookmarks.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.library_books_outlined,
      title: 'Start Your Library',
      message: 'Add your first book to begin reading',
      actionLabel: 'Add Book',
      onAction: () {
        // Navigation handled by main screen
      },
    );
  }
}

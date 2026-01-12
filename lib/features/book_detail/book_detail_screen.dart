import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/book.dart';
import '../../data/repositories/book_repository.dart';
import '../book_form/book_form_screen.dart';
import '../reader/reader_screen.dart';

/// BookDetailScreen - Layar detail buku
/// 
/// Menampilkan informasi lengkap buku:
/// - Header: cover, title, author, tags
/// - Progress: circular & linear progress indicator
/// - Bookmarks: list halaman yang di-bookmark
/// - Actions: Continue Reading, Edit, Share, Delete (placeholder)
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentBook.title,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            _buildHeader(context),
            const SizedBox(height: 24),
            
            // Progress Section
            _buildProgressCard(context),
            const SizedBox(height: 16),
            
            // Bookmarks Section
            _buildBookmarksCard(context),
            const SizedBox(height: 24),
            
            // Actions Section
            _buildActions(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Build header section
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // PDF Icon/Cover placeholder
        Container(
          width: 100,
          height: 140,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.picture_as_pdf,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Title
        Text(
          _currentBook.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Author
        Text(
          _currentBook.author,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        
        // Tags
        if (_currentBook.tags.isNotEmpty)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: _currentBook.tags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
        
        // Added date
        Text(
          'Ditambahkan: ${DateFormat('dd MMM yyyy').format(_currentBook.addedAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  /// Build progress card
  Widget _buildProgressCard(BuildContext context) {
    final progress = _currentBook.readingProgress;
    final isCompleted = _currentBook.isCompleted;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Section title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress Membaca',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'SELESAI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Circular progress
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: progress / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[300],
                      color: isCompleted 
                        ? Colors.green 
                        : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.green : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Linear progress
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                color: isCompleted 
                  ? Colors.green 
                  : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            
            // Page info
            Text(
              'Halaman ${_currentBook.lastPage} dari ${_currentBook.totalPages}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build bookmarks card
  Widget _buildBookmarksCard(BuildContext context) {
    final hasBookmarks = _currentBook.bookmarks.isNotEmpty;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              'Bookmarks (${_currentBook.bookmarks.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Bookmarks list or empty state
            if (hasBookmarks)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _currentBook.bookmarks.map((page) {
                  return ActionChip(
                    label: Text('Hal. $page'),
                    avatar: const Icon(Icons.bookmark, size: 16),
                    onPressed: () => _handleJumpToBookmark(context, page),
                  );
                }).toList(),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada bookmark',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build actions section
  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary action: Continue Reading
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _handleContinueReading(context),
            icon: const Icon(Icons.play_arrow),
            label: Text(
              _currentBook.lastPage > 0 ? 'Lanjutkan Membaca' : 'Mulai Membaca',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Secondary actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Edit
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleEdit(context),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 8),
            
            // Share
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleShare(context),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ),
            const SizedBox(width: 8),
            
            // Delete
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleDelete(context),
                icon: const Icon(Icons.delete),
                label: const Text('Hapus'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

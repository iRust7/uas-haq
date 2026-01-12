import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../data/models/book.dart';
import '../../data/repositories/book_repository.dart';

/// ReaderScreen - PDF Reader dengan progress tracking
/// 
/// Features:
/// - Display PDF from filePathOrUri
/// - Auto-save lastPage saat membaca
/// - Auto-update totalPages saat pertama dibuka
/// - Restore ke lastPage saat dibuka kembali
class ReaderScreen extends StatefulWidget {
  final Book book;
  
  const ReaderScreen({
    super.key,
    required this.book,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isReady = false;
  String? _errorMessage;
  final _bookRepository = BookRepository();

  @override
  void initState() {
    super.initState();
    // Start from last saved page (0-indexed for controller)
    _currentPage = widget.book.lastPage > 0 ? widget.book.lastPage - 1 : 0;
  }

  /// Check if current page is bookmarked
  bool get _isCurrentPageBookmarked {
    return widget.book.bookmarks.contains(_currentPage + 1); // 1-indexed
  }

  /// Toggle bookmark for current page
  Future<void> _toggleBookmark() async {
    final pageNumber = _currentPage + 1; // Convert to 1-indexed
    
    if (widget.book.bookmarks.contains(pageNumber)) {
      widget.book.bookmarks.remove(pageNumber);
      await widget.book.save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bookmark halaman $pageNumber dihapus'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      widget.book.bookmarks.add(pageNumber);
      widget.book.bookmarks.sort(); // Keep sorted
      await widget.book.save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Halaman $pageNumber di-bookmark'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
    
    setState(() {});
  }

  /// Called when PDF is rendered
  void _onPdfViewCreated(PDFViewController controller) {
    // PDF ready
  }

  /// Called when PDF document is rendered
  void _onRender(int? pages) {
    setState(() {
      _totalPages = pages ?? 0;
      _isReady = true;
    });
    
    // Update total pages in Hive if not set or changed
    if (widget.book.totalPages != _totalPages) {
      widget.book.totalPages = _totalPages;
      widget.book.save();
    }
  }

  /// Called when page changes
  void _onPageChanged(int? page, int? total) async {
    if (page == null) return;
    
    setState(() {
      _currentPage = page;
      if (total != null) _totalPages = total;
    });
    
    // Update book directly in Hive
    widget.book.lastPage = page + 1; // Convert to 1-indexed
    widget.book.lastReadAt = DateTime.now(); // Track when book was last read
    if (total != null) {
      widget.book.totalPages = total;
    }
    
    // Save to Hive
    await widget.book.save();
  }

  /// Called on PDF error
  void _onError(dynamic error) {
    setState(() {
      _errorMessage = error.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book.title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Bookmark button
          if (_isReady)
            IconButton(
              icon: Icon(
                _isCurrentPageBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _isCurrentPageBookmarked ? Colors.amber : null,
              ),
              onPressed: _toggleBookmark,
              tooltip: _isCurrentPageBookmarked ? 'Hapus Bookmark' : 'Tambah Bookmark',
            ),
          // Page indicator
          if (_isReady)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Hal ${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: _errorMessage != null
          ? _buildErrorView()
          : Stack(
              children: [
                PDFView(
                  filePath: widget.book.filePathOrUri,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: true,
                  defaultPage: _currentPage,
                  fitPolicy: FitPolicy.BOTH,
                  preventLinkNavigation: false,
                  onViewCreated: _onPdfViewCreated,
                  onRender: _onRender,
                  onPageChanged: _onPageChanged,
                  onError: _onError,
                  onPageError: (page, error) {
                    setState(() {
                      _errorMessage = 'Error on page $page: $error';
                    });
                  },
                ),
                if (!_isReady)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal Membuka PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}

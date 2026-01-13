import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/book.dart';
import '../../data/models/reading_session.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/reading_session_repository.dart';

/// ReaderScreen - Complete PDF Reader with full overlay controls
/// 
/// Fixed version with:
/// - Better tap detection (no conflict dengan PDF gestures)
/// - Manual overlay toggle (no auto-hide bugs)
/// - Working next/prev navigation
/// - Dark mode untuk UI (not PDF content - that's a package limitation)
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
  final _sessionRepository = ReadingSessionRepository();
  ReadingSession? _currentSession;
  
  // Overlay state
  bool _showOverlay = true;
  Timer? _hideOverlayTimer;
  
  // Slider state
  int _sliderPage = 0;
  bool _isDraggingSlider = false;
  
  // Reader settings
  bool _isDarkMode = false;
  
  // PDF Controller  
  PDFViewController? _pdfController;
  
  // Key for rebuilding PDF widget
  Key _pdfKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _currentPage = widget.book.lastPage > 0 ? widget.book.lastPage - 1 : 0;
    _sliderPage = _currentPage;
    _startReadingSession();
  }
  
  @override
  void dispose() {
    _hideOverlayTimer?.cancel();
    _endReadingSession();
    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
  
  void _startReadingSession() {
    _currentSession = ReadingSession(
      id: const Uuid().v4(),
      bookId: widget.book.id,
      startTime: DateTime.now(),
      startPage: _currentPage + 1,
    );
    _sessionRepository.createSession(_currentSession!);
  }
  
  void _endReadingSession() {
    if (_currentSession != null && _currentSession!.isActive) {
      _currentSession!.endSession(finalPage: _currentPage + 1);
      _sessionRepository.updateSession(_currentSession!);
    }
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  bool get _isCurrentPageBookmarked {
    return widget.book.bookmarks.contains(_currentPage + 1);
  }

  Future<void> _toggleBookmark() async {
    final pageNumber = _currentPage + 1;
    
    if (widget.book.bookmarks.contains(pageNumber)) {
      widget.book.bookmarks.remove(pageNumber);
      await widget.book.save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bookmark removed from page $pageNumber'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      widget.book.bookmarks.add(pageNumber);
      widget.book.bookmarks.sort();
      await widget.book.save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Page $pageNumber bookmarked'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
    
    setState(() {});
  }
  
  void _jumpToPage(int page) {
    if (page < 0 || page >= _totalPages) return;
    if (page == _currentPage) return;
    
    setState(() {
      _currentPage = page;
      _sliderPage = page;
      _isDraggingSlider = false;
      // Force PDF rebuild with new page
      _pdfKey = UniqueKey();
    });
    
    _savePageProgress();
  }
  
  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _jumpToPage(_currentPage - 1);
    }
  }
  
  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      _jumpToPage(_currentPage + 1);
    }
  }
  
  Future<void> _savePageProgress() async {
    widget.book.lastPage = _currentPage + 1;
    widget.book.lastReadAt = DateTime.now();
    await widget.book.save();
    
    if (_currentSession != null) {
      _currentSession!.endPage = _currentPage + 1;
      await _sessionRepository.updateSession(_currentSession!);
    }
  }
  
  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      // Rebuild PDF with new background
      _pdfKey = UniqueKey();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isDarkMode 
          ? 'Dark mode enabled (UI only - PDF content unchanged)' 
          : 'Light mode enabled'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _showBookmarksList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'BOOKMARKS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (widget.book.bookmarks.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No bookmarks yet',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.book.bookmarks.length,
                  itemBuilder: (context, index) {
                    final page = widget.book.bookmarks[index];
                    return ListTile(
                      leading: Icon(
                        Icons.bookmark,
                        color: Colors.amber[700],
                      ),
                      title: Text(
                        'Page $page',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _jumpToPage(page - 1);
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'READER SETTINGS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: const Text('Changes UI background only'),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  Navigator.pop(context);
                  _toggleDarkMode();
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.screen_rotation),
              title: Text(
                'Rotate Screen',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: const Text('Lock to landscape/portrait'),
              onTap: () {
                Navigator.pop(context);
                _showOrientationMenu();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(
                'Zoom Tip',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: const Text('Use pinch gesture to zoom'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  void _showOrientationMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Screen Orientation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Portrait'),
              leading: const Icon(Icons.stay_current_portrait),
              onTap: () {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Landscape'),
              leading: const Icon(Icons.stay_current_landscape),
              onTap: () {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Auto'),
              leading: const Icon(Icons.screen_rotation),
              onTap: () {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onPdfViewCreated(PDFViewController controller) {
    _pdfController = controller;
  }

  void _onRender(int? pages) {
    setState(() {
      _totalPages = pages ?? 0;
      _isReady = true;
      // Clamp slider to valid range
      if (_sliderPage >= _totalPages && _totalPages > 0) {
        _sliderPage = _totalPages - 1;
        _currentPage = _sliderPage;
      }
    });
    
    if (widget.book.totalPages != _totalPages) {
      widget.book.totalPages = _totalPages;
      widget.book.save();
    }
  }

  void _onPageChanged(int? page, int? total) async {
    if (page == null) return;
    
    setState(() {
      _currentPage = page;
      _sliderPage = page;
      if (total != null) _totalPages = total;
    });
    
    await _savePageProgress();
  }

  void _onError(dynamic error) {
    setState(() {
      _errorMessage = error.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? Colors.grey[900]! : Colors.grey[200]!;
    
    return Scaffold(
      backgroundColor: bgColor,
      body: _errorMessage != null
          ? _buildErrorView()
          : Stack(
              children: [
                // PDF View - NO gesture detector wrapping
                Container(
                  color: bgColor,
                  child: PDFView(
                    key: _pdfKey, // Force rebuild when page changes
                    filePath: widget.book.filePathOrUri,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: true,
                    pageFling: true,
                    pageSnap: true,
                    defaultPage: _currentPage,
                    fitPolicy: FitPolicy.BOTH,
                    preventLinkNavigation: false,
                    backgroundColor: bgColor,
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
                ),
                
                // Transparent overlay for tap detection (only when overlay hidden)
                if (!_showOverlay)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _toggleOverlay,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                
                // Loading indicator
                if (!_isReady)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.teal,
                    ),
                  ),
                
                // Overlays
                if (_showOverlay) ...[
                  _buildTopBar(),
                  _buildBottomControls(),
                ],
                
                // Page preview (always on top)
                _buildPagePreview(),
              ],
            ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {}, // Prevent tap from propagating
        child: Container(
          decoration: BoxDecoration(
            color: Colors.teal[700],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Back',
                  ),
                  Expanded(
                    child: Text(
                      widget.book.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Search feature coming soon'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    tooltip: 'Search',
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_size, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Use pinch gesture to zoom'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Text Size',
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: _showSettingsMenu,
                    tooltip: 'Settings',
                  ),
                  // Hide overlay button
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _showOverlay = false;
                      });
                    },
                    tooltip: 'Hide Controls',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {}, // Prevent tap from propagating
        child: Container(
          decoration: BoxDecoration(
            color: _isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[300],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Slider section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: _isDarkMode ? Colors.white : Colors.black87,
                          size: 28,
                        ),
                        onPressed: _currentPage > 0 ? _goToPreviousPage : null,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.teal,
                            inactiveTrackColor: _isDarkMode ? Colors.white24 : Colors.black26,
                            thumbColor: Colors.teal,
                            overlayColor: Colors.teal.withOpacity(0.2),
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 7,
                            ),
                          ),
                          child: Slider(
                            min: 0,
                            max: _totalPages > 0 ? (_totalPages - 1).toDouble() : 0,
                            value: (_totalPages > 0 ? _sliderPage.clamp(0, _totalPages - 1) : 0).toDouble(),
                            onChanged: _totalPages > 0 ? (value) {
                              setState(() {
                                _sliderPage = value.toInt();
                                _isDraggingSlider = true;
                              });
                            } : null,
                            onChangeEnd: _totalPages > 0 ? (value) {
                              _jumpToPage(value.toInt());
                            } : null,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isDarkMode ? Colors.black26 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentPage + 1}/$_totalPages',
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: _isDarkMode ? Colors.white : Colors.black87,
                          size: 28,
                        ),
                        onPressed: _currentPage < _totalPages - 1 ? _goToNextPage : null,
                      ),
                    ],
                  ),
                ),
                
                // Toolbar
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: _isDarkMode ? Colors.white12 : Colors.black12,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildToolbarButton(
                        icon: _isCurrentPageBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        label: 'Bookmark',
                        onPressed: _toggleBookmark,
                        color: _isCurrentPageBookmarked ? Colors.amber : null,
                      ),
                      _buildToolbarButton(
                        icon: _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        label: 'Theme',
                        onPressed: _toggleDarkMode,
                      ),
                      _buildToolbarButton(
                        icon: Icons.list,
                        label: 'Bookmarks',
                        onPressed: _showBookmarksList,
                      ),
                      _buildToolbarButton(
                        icon: Icons.settings,
                        label: 'Settings',
                        onPressed: _showSettingsMenu,
                      ),
                      _buildToolbarButton(
                        icon: Icons.more_horiz,
                        label: 'More',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('More options coming soon'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: color ?? (_isDarkMode ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: _isDarkMode ? Colors.white60 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagePreview() {
    return Positioned(
      top: MediaQuery.of(context).size.height / 2 - 50,
      left: MediaQuery.of(context).size.width / 2 - 60,
      child: AnimatedOpacity(
        opacity: _isDraggingSlider ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal, width: 2),
          ),
          child: Text(
            'Page ${_sliderPage + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
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
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Open PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

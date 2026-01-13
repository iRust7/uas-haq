import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../core/utils/validators.dart';
import '../../core/services/pdf_thumbnail_service.dart';
import '../../data/models/book.dart';
import '../../data/repositories/book_repository.dart';

/// BookFormScreen - Modern add/edit book form
/// 
/// Features:
/// - Bold header with clear mode indication
/// - Enhanced PDF picker with visual feedback
/// - Large cover preview with shadow
/// - Modern form fields with icons
/// - Gradient action buttons
class BookFormScreen extends StatefulWidget {
  final Book? book; // null = add mode, non-null = edit mode
  
  const BookFormScreen({
    super.key,
    this.book,
  });

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _tagsController = TextEditingController();
  final _totalPagesController = TextEditingController();
  final _bookRepository = BookRepository();
  
  bool _isLoading = false;
  bool get _isEditMode => widget.book != null;
  
  // File picker state
  String? _selectedFilePath;
  String? _selectedFileName;
  String? _thumbnailPreviewPath;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields jika edit mode
    if (_isEditMode) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _tagsController.text = widget.book!.tags.join(', ');
      if (widget.book!.totalPages > 0) {
        _totalPagesController.text = widget.book!.totalPages.toString();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _tagsController.dispose();
    _totalPagesController.dispose();
    super.dispose();
  }

  /// Validasi total pages
  String? _validateTotalPages(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final pages = int.tryParse(value);
    if (pages == null || pages < 1) {
      return 'Harus berupa angka positif';
    }
    return null;
  }

  /// Parse tags dari comma-separated string
  List<String> _parseTags(String tagsString) {
    if (tagsString.trim().isEmpty) return [];
    
    return tagsString
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  /// Handle pick PDF file
  Future<void> _handlePickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        
        setState(() {
          _selectedFilePath = file.path;
          _selectedFileName = file.name;
          
          // Auto-fill title from filename (without .pdf extension)
          if (_titleController.text.isEmpty) {
            _titleController.text = file.name
              .replaceAll('.pdf', '')
              .replaceAll('_', ' ')
              .replaceAll('-', ' ');
          }
        });
        
        // Generate thumbnail preview
        _generateThumbnailPreview(file.path!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File "${file.name}" dipilih'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memilih file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Generate thumbnail preview from selected PDF
  Future<void> _generateThumbnailPreview(String pdfPath) async {
    try {
      final tempId = 'preview_${DateTime.now().millisecondsSinceEpoch}';
      final thumbnailPath = await PdfThumbnailService.getThumbnail(
        bookId: tempId,
        pdfPath: pdfPath,
      );
      
      if (thumbnailPath != null && mounted) {
        setState(() {
          _thumbnailPreviewPath = thumbnailPath;
        });
      }
    } catch (e) {
      print('Error generating thumbnail preview: $e');
    }
  }

  /// Copy file to app storage
  Future<String?> _copyFileToAppStorage(String sourcePath, String bookId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${directory.path}/books');
      
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }
      
      final sourceFile = File(sourcePath);
      final fileName = path.basename(sourcePath);
      final targetPath = '${booksDir.path}/$bookId-$fileName';
      
      await sourceFile.copy(targetPath);
      return targetPath;
    } catch (e) {
      return null;
    }
  }

  /// Handle save book
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final bookId = _isEditMode ? widget.book!.id : const Uuid().v4();
      
      // Handle file path
      String filePathOrUri;
      
      if (_selectedFilePath != null) {
        final copiedPath = await _copyFileToAppStorage(_selectedFilePath!, bookId);
        
        if (copiedPath == null) {
          throw Exception('Gagal menyalin file PDF');
        }
        
        filePathOrUri = copiedPath;
      } else if (_isEditMode) {
        filePathOrUri = widget.book!.filePathOrUri;
      } else {
        filePathOrUri = '/storage/books/${_titleController.text.trim().toLowerCase().replaceAll(' ', '_')}.pdf';
      }
      
      final book = Book(
        id: bookId,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        tags: _parseTags(_tagsController.text),
        filePathOrUri: filePathOrUri,
        addedAt: _isEditMode ? widget.book!.addedAt : DateTime.now(),
        lastPage: _isEditMode ? widget.book!.lastPage : 0,
        totalPages: _totalPagesController.text.trim().isEmpty 
            ? (_isEditMode ? widget.book!.totalPages : 0)
            : int.parse(_totalPagesController.text.trim()),
        bookmarks: _isEditMode ? widget.book!.bookmarks : [],
      );
      
      // Generate cover thumbnail
      if (_selectedFilePath != null) {
        try {
          await PdfThumbnailService.getThumbnail(
            bookId: bookId,
            pdfPath: filePathOrUri,
          );
        } catch (e) {
          print('Failed to generate thumbnail: $e');
        }
      }
      
      final bool success;
      if (_isEditMode) {
        success = await _bookRepository.updateBook(book);
      } else {
        success = await _bookRepository.createBook(book);
      }
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode 
                ? 'Buku "${book.title}" berhasil diupdate'
                : 'Buku "${book.title}" berhasil ditambahkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Gagal update buku' : 'Gagal menambah buku'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          _isEditMode ? 'EDIT BOOK' : 'ADD NEW BOOK',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(isDark),
              const SizedBox(height: 32),
              
              // PDF Picker Section
              _buildPDFPicker(isDark),
              const SizedBox(height: 24),
              
              // Cover Preview (if available)
              if (_thumbnailPreviewPath != null) ...[
                _buildCoverPreview(isDark),
                const SizedBox(height: 24),
              ],
              
              // Form Fields
              _buildFormFields(isDark),
              const SizedBox(height: 32),
              
              // Action Buttons
              _buildActionButtons(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _isEditMode ? Colors.purple[600] : Colors.blue[600],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            _isEditMode ? Icons.edit_note : Icons.add_box,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isEditMode ? 'EDIT BOOK INFO' : 'ADD NEW BOOK',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isEditMode ? 'Update book information' : 'Fill in book details below',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildPDFPicker(bool isDark) {
    final hasFile = _selectedFileName != null;
    
    return GestureDetector(
      onTap: _isLoading ? null : _handlePickPDF,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasFile 
              ? Colors.green[600]! 
              : (isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
            width: 2,
            style: hasFile ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: hasFile ? Colors.green[600] : Colors.blue[600],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                hasFile ? Icons.check_circle : Icons.upload_file,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFile ? 'PDF FILE SELECTED' : 'SELECT PDF FILE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: hasFile 
                  ? Colors.green[600] 
                  : (isDark ? Colors.white : Colors.black),
              ),
            ),
            const SizedBox(height: 8),
            if (hasFile)
              Text(
                _selectedFileName!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              )
            else
              Text(
                'Tap to browse PDF files',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            const SizedBox(height: 16),
            if (!hasFile)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'BROWSE FILES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _handlePickPDF,
                    child: const Text(
                      'CHANGE FILE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilePath = null;
                        _selectedFileName = null;
                        _thumbnailPreviewPath = null;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text(
                      'REMOVE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPreview(bool isDark) {
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
        children: [
          Text(
            'COVER PREVIEW',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_thumbnailPreviewPath!),
                width: 200,
                height: 280,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 280,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'From PDF page 1',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BOOK INFORMATION',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        
        // Title field
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Book Title *',
            hintText: 'Enter book title',
            prefixIcon: const Icon(Icons.book),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
              ),
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textInputAction: TextInputAction.next,
          validator: (value) => Validators.validateRequired(value, 'Judul'),
        ),
        const SizedBox(height: 16),
        
        // Author field
        TextFormField(
          controller: _authorController,
          decoration: InputDecoration(
            labelText: 'Author *',
            hintText: 'Enter author name',
            prefixIcon: const Icon(Icons.person),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
              ),
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textInputAction: TextInputAction.next,
          validator: (value) => Validators.validateRequired(value, 'Penulis'),
        ),
        const SizedBox(height: 16),
        
        // Tags field
        TextFormField(
          controller: _tagsController,
          decoration: InputDecoration(
            labelText: 'Tags (Optional)',
            hintText: 'Programming, Flutter, Mobile',
            helperText: 'Separate with commas',
            prefixIcon: const Icon(Icons.label),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
              ),
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        
        // Total pages field
        TextFormField(
          controller: _totalPagesController,
          decoration: InputDecoration(
            labelText: 'Total Pages (Optional)',
            hintText: 'Example: 500',
            prefixIcon: const Icon(Icons.numbers),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
              ),
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          validator: _validateTotalPages,
          onFieldSubmitted: (_) => _handleSave(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        // Save Button - Gradient
        Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isEditMode 
                ? [Colors.purple[600]!, Colors.purple[800]!]
                : [Colors.blue[600]!, Colors.blue[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (_isEditMode ? Colors.purple : Colors.blue).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _isEditMode ? 'SAVE CHANGES' : 'ADD BOOK',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Cancel Button
        SizedBox(
          height: 56,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'CANCEL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

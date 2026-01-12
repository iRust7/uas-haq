import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import '../../core/utils/validators.dart';
import '../../core/services/pdf_thumbnail_service.dart';
import '../../data/models/book.dart';
import '../../data/repositories/book_repository.dart';

/// BookFormScreen - Form untuk Add atau Edit buku
/// 
/// Mode:
/// - Add: book == null
/// - Edit: book != null
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
  String? _thumbnailPreviewPath; // Preview of generated thumbnail

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
    // Request storage permission first (Android runtime permission)
    final granted = await _requestStoragePermission();
    if (!granted) return;
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

  /// Request storage permission on Android
  Future<bool> _requestStoragePermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final status = await Permission.storage.status;
      if (status.isGranted) return true;

      final result = await Permission.storage.request();
      if (result.isGranted) return true;

      if (result.isPermanentlyDenied) {
        if (!mounted) return false;
        // Prompt user to open app settings
        final open = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Izin Penyimpanan Diperlukan'),
            content: const Text('Agar dapat mengimpor file PDF, izinkan akses penyimpanan dari Pengaturan.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Buka Pengaturan')),
            ],
          ),
        );

        if (open == true) {
          await openAppSettings();
        }
      } else {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin penyimpanan diperlukan untuk memilih file PDF.'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Generate thumbnail preview from selected PDF
  Future<void> _generateThumbnailPreview(String pdfPath) async {
    try {
      // Generate temporary thumbnail with a temp ID
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
      // Silently fail - thumbnail preview is optional
      print('Error generating thumbnail preview: $e');
    }
  }

  /// Copy file to app storage
  Future<String?> _copyFileToAppStorage(String sourcePath, String bookId) async {
    try {
      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${directory.path}/books');
      
      // Create books directory if not exists
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }
      
      // Copy file
      final sourceFile = File(sourcePath);
      final fileName = path.basename(sourcePath);
      final targetPath = '${booksDir.path}/$bookId-$fileName';
      
      await sourceFile.copy(targetPath);
      
      return targetPath;
    } catch (e) {
      // Error copying file, return null
      return null;
    }
  }

  /// Handle save book
  Future<void> _handleSave() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final bookId = _isEditMode ? widget.book!.id : const Uuid().v4();
      
      // Handle file path
      String filePathOrUri;
      
      if (_selectedFilePath != null) {
        // Copy file to app storage
        final copiedPath = await _copyFileToAppStorage(_selectedFilePath!, bookId);
        
        if (copiedPath == null) {
          throw Exception('Gagal menyalin file PDF');
        }
        
        filePathOrUri = copiedPath;
      } else if (_isEditMode) {
        // Keep existing path
        filePathOrUri = widget.book!.filePathOrUri;
      } else {
        // Placeholder (no file selected when adding)
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
      
      // Generate cover thumbnail from PDF first page
      if (_selectedFilePath != null) {
        try {
          await PdfThumbnailService.getThumbnail(
            bookId: bookId,
            pdfPath: filePathOrUri,
          );
        } catch (e) {
          // Thumbnail generation failed, but continue with book save
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
        // Show success message
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
        
        // Pop dengan result true
        Navigator.pop(context, true);
      } else {
        // Show error
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Buku' : 'Tambah Buku'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                _isEditMode ? Icons.edit_note : Icons.add_box,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              
              Text(
                _isEditMode ? 'Edit informasi buku' : 'Tambahkan buku baru ke library',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              // PDF Cover Preview Section (if thumbnail is available)
              if (_thumbnailPreviewPath != null)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Preview Cover Buku',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
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
                          const SizedBox(height: 8),
                          Text(
                            'Cover diambil dari halaman pertama PDF',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              
              // PDF File Picker Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedFileName != null ? Colors.green.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedFileName != null ? Colors.green.shade200 : Colors.blue.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFileName != null ? Icons.check_circle : Icons.upload_file,
                      size: 48,
                      color: _selectedFileName != null ? Colors.green.shade700 : Colors.blue.shade700,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFileName ?? 'Belum ada file PDF dipilih',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedFileName != null ? Colors.green.shade700 : Colors.grey[700],
                      ),
                    ),
                    if (_selectedFileName != null)
                      const SizedBox(height: 4),
                    if (_selectedFileName != null)
                      Text(
                        'File sudah dipilih',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade600,
                        ),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handlePickPDF,
                      icon: const Icon(Icons.folder_open),
                      label: Text(
                        _selectedFileName != null ? 'GANTI FILE PDF' : 'PILIH FILE PDF',
                      ),
                    ),
                    if (_selectedFileName != null)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedFilePath = null;
                            _selectedFileName = null;
                          });
                        },
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Hapus Pilihan'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Buku *',
                  hintText: 'Masukkan judul buku',
                  prefixIcon: Icon(Icons.book),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.validateRequired(value, 'Judul'),
              ),
              const SizedBox(height: 16),
              
              // Author field
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Penulis *',
                  hintText: 'Masukkan nama penulis',
                  prefixIcon: Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.validateRequired(value, 'Penulis'),
              ),
              const SizedBox(height: 16),
              
              // Tags field
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (opsional)',
                  hintText: 'Programming, Flutter, Mobile',
                  helperText: 'Pisahkan dengan koma',
                  prefixIcon: Icon(Icons.label),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              
              // Total pages field
              TextFormField(
                controller: _totalPagesController,
                decoration: const InputDecoration(
                  labelText: 'Total Halaman (opsional)',
                  hintText: 'Contoh: 500',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
                validator: _validateTotalPages,
                onFieldSubmitted: (_) => _handleSave(),
              ),
              const SizedBox(height: 24),
              
              // Save button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
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
                        _isEditMode ? 'SIMPAN PERUBAHAN' : 'TAMBAH BUKU',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Cancel button
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('BATAL'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

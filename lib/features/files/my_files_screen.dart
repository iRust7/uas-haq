import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import '../reader/reader_screen.dart';
import '../../data/models/book.dart';
import '../../data/repositories/starred_folders_repository.dart';
import '../../data/repositories/book_repository.dart';

/// MyFilesScreen - Enhanced PDF file browser with full file management
class MyFilesScreen extends StatefulWidget {
  final String? initialPath;
  
  const MyFilesScreen({super.key, this.initialPath});

  @override
  State<MyFilesScreen> createState() => _MyFilesScreenState();
}

class _MyFilesScreenState extends State<MyFilesScreen> {
  Directory? _currentDirectory;
  List<FileSystemEntity> _entities = [];
  List<FileSystemEntity> _filtered = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  
  final _starredRepo = StarredFoldersRepository();
  final _bookRepo = BookRepository();
  
  // Filter settings
  bool _showOnlyPDFs = false;
  bool _showOnlyFolders = false;
  
  @override
  void initState() {
    super.initState();
    _starredRepo.init().then((_) {
      _requestPermissionAndBrowse();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _requestPermissionAndBrowse() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      PermissionStatus status;
      
      if (Platform.isAndroid && await Permission.manageExternalStorage.status.isGranted) {
        status = PermissionStatus.granted;
      } else if (Platform.isAndroid && await Permission.storage.status.isGranted) {
        status = PermissionStatus.granted;
      } else {
        if (await Permission.manageExternalStorage.request().isGranted) {
           status = PermissionStatus.granted;
        } else if (await Permission.storage.request().isGranted) {
           status = PermissionStatus.granted;
        } else {
           status = PermissionStatus.denied;
        }
      }
      
      if (status.isGranted) {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final rootPath = directory.path.split('/Android')[0];
          _currentDirectory = Directory(widget.initialPath ?? rootPath);
          await _loadDirectory();
        } else {
          setState(() {
            _errorMessage = 'Could not access storage';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Permission denied.\nPlease grant "All files access" in settings to browse files.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error accessing storage: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadDirectory() async {
    if (_currentDirectory == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final entities = await _currentDirectory!.list().toList();
      
      // Filter: directories and PDF files only
      final filtered = entities.where((entity) {
        if (entity is Directory) return true;
        if (entity is File) {
          return path.extension(entity.path).toLowerCase() == '.pdf';
        }
        return false;
      }).toList();
      
      // Sort: directories first, then files, alphabetically
      filtered.sort((a, b) {
        if (a is Directory && b is File) return -1;
        if (a is File && b is Directory) return 1;
        return path.basename(a.path).toLowerCase()
            .compareTo(path.basename(b.path).toLowerCase());
      });
      
      setState(() {
        _entities = filtered;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Cannot access this folder';
        _isLoading = false;
      });
    }
  }
  
  void _applyFilters() {
    var result = _entities;
    
    // Apply type filters
    if (_showOnlyPDFs) {
      result = result.where((e) => e is File).toList();
    } else if (_showOnlyFolders) {
      result = result.where((e) => e is Directory).toList();
    }
    
    // Apply search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      result = result.where((e) {
        return path.basename(e.path).toLowerCase().contains(query);
      }).toList();
    }
    
    setState(() {
      _filtered = result;
    });
  }
  
  void _navigateToDirectory(Directory dir) {
    setState(() {
      _currentDirectory = dir;
      _searchController.clear();
_isSearching = false;
    });
    _loadDirectory();
  }
  
  void _navigateUp() {
    if (_currentDirectory != null && _currentDirectory!.parent.existsSync()) {
      _navigateToDirectory(_currentDirectory!.parent);
    }
  }
  
  Future<void> _openPdf(File file) async {
    final book = Book(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      title: path.basenameWithoutExtension(file.path),
      author: 'Unknown',
      filePathOrUri: file.path,
      addedAt: DateTime.now(),
    );
    
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReaderScreen(book: book),
        ),
      );
    }
  }
  
  // File operations
  void _showFileMenu(File file) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FileOperationsMenu(
        file: file,
        onOperation: (op) => _handleFileOperation(file, op),
      ),
    );
  }
  
  Future<void> _handleFileOperation(File file, String operation) async {
    Navigator.pop(context); // Close menu
    
    switch (operation) {
      case 'info':
        await _showFileInfo(file);
        break;
      case 'delete':
        await _deleteFile(file);
        break;
      case 'rename':
        await _renameFile(file);
        break;
      case 'share':
        await Share.shareXFiles([XFile(file.path)]);
        break;
      case 'add_to_home':
        await _addToLibrary(file);
        break;
    }
  }
  
  Future<void> _showFileInfo(File file) async {
    final stat = await file.stat();
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(path.basename(file.path)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Path: ${file.path}'),
              Text('Size: ${(stat.size / 1024 / 1024).toStringAsFixed(2)} MB'),
              Text('Modified: ${stat.modified.toString().split('.')[0]}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
  
  Future<void> _deleteFile(File file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Delete ${path.basename(file.path)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await file.delete();
        _loadDirectory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
  
  Future<void> _renameFile(File file) async {
    final controller = TextEditingController(text: path.basenameWithoutExtension(file.path));
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    
    if (newName != null && newName.isNotEmpty) {
      try {
        final ext = path.extension(file.path);
        final newPath = path.join(path.dirname(file.path), '$newName$ext');
        await file.rename(newPath);
        _loadDirectory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File renamed')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
  
  Future<void> _addToLibrary(File file) async {
    try {
      final book = Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: path.basenameWithoutExtension(file.path),
        author: 'Unknown',
        filePathOrUri: file.path,
        addedAt: DateTime.now(),
      );
      await _bookRepo.addBook(book);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to library'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  Future<void> _createFolder() async {
    final controller = TextEditingController();
    final folderName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    
    if (folderName != null && folderName.isNotEmpty && _currentDirectory != null) {
      try {
        final newDir = Directory(path.join(_currentDirectory!.path, folderName));
        await newDir.create();
        _loadDirectory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Folder created')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
  
  void _toggleStar(Directory dir) async {
    await _starredRepo.toggleStar(dir.path);
    setState(() {}); // Refresh UI
  }
  
  void _showFilterMenu() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Show Only PDFs'),
              value: _showOnlyPDFs,
              onChanged: (val) {
                setState(() {
                  _showOnlyPDFs = val ?? false;
                  if (_showOnlyPDFs) _showOnlyFolders = false;
                });
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            CheckboxListTile(
              title: const Text('Show Only Folders'),
              value: _showOnlyFolders,
              onChanged: (val) {
                setState(() {
                  _showOnlyFolders = val ?? false;
                  if (_showOnlyFolders) _showOnlyPDFs = false;
                });
                Navigator.pop(context);
                _applyFilters();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _showOnlyPDFs = false;
                _showOnlyFolders = false;
              });
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search files...',
                  border: InputBorder.none,
                ),
                onChanged: (_) => _applyFilters(),
              )
            : const Text('My Files'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
                _applyFilters();
              },
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _isSearching = true),
              tooltip: 'Search',
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterMenu,
              tooltip: 'Filter',
            ),
            IconButton(
              icon: const Icon(Icons.create_new_folder),
              onPressed: _createFolder,
              tooltip: 'Create Folder',
            ),
            if (_currentDirectory != null)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadDirectory,
                tooltip: 'Refresh',
              ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildFileList(),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (_errorMessage!.contains('permission'))
              ElevatedButton.icon(
                onPressed: () async => await openAppSettings(),
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
              )
            else
              ElevatedButton.icon(
                onPressed: _requestPermissionAndBrowse,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFileList() {
    return Column(
      children: [
        // Current path
        Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Row(
            children: [
              if (_currentDirectory!.parent.existsSync())
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: _navigateUp,
                  tooltip: 'Up',
                ),
              Expanded(
                child: Text(
                  _currentDirectory!.path,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        
        // File/folder list
        Expanded(
          child: _filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No ${_showOnlyPDFs ? "PDFs" : _showOnlyFolders ? "folders" : "items"} found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final entity = _filtered[index];
                    return _buildEntityTile(entity);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildEntityTile(FileSystemEntity entity) {
    final isDirectory = entity is Directory;
    final name = path.basename(entity.path);
    final isStarred = isDirectory && _starredRepo.isStarred(entity.path);
    
    return ListTile(
      leading: Icon(
        isDirectory ? Icons.folder : Icons.picture_as_pdf,
        color: isDirectory ? Colors.amber : Colors.red[300],
        size: 32,
      ),
      title: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: isDirectory ? const Text('Folder') : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDirectory)
            IconButton(
              icon: Icon(
                isStarred ? Icons.star : Icons.star_border,
                color: isStarred ? Colors.amber : null,
              ),
              onPressed: () => _toggleStar(entity as Directory),
            ),
          if (!isDirectory)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showFileMenu(entity as File),
            ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () {
        if (isDirectory) {
          _navigateToDirectory(entity as Directory);
        } else {
          _openPdf(entity as File);
        }
      },
    );
  }
}

class _FileOperationsMenu extends StatelessWidget {
  final File file;
  final Function(String) onOperation;
  
  const _FileOperationsMenu({required this.file, required this.onOperation});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Book Information'),
          onTap: () => onOperation('info'),
        ),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Delete File'),
          onTap: () => onOperation('delete'),
        ),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Rename'),
          onTap: () => onOperation('rename'),
        ),
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Send To'),
          onTap: () => onOperation('share'),
        ),
        ListTile(
          leading: const Icon(Icons.add_to_home_screen),
          title: const Text('Add to Library'),
          onTap: () => onOperation('add_to_home'),
        ),
      ],
    );
  }
}

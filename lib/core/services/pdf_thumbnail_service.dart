import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'dart:ui' as ui;

/// PDF Thumbnail Service
/// 
/// Generates and caches PDF first-page thumbnails for book covers
class PdfThumbnailService {
  // Thumbnail dimensions - increased for better quality
  static const double thumbnailWidth = 400;
  static const double thumbnailHeight = 560;
  
  /// Generate thumbnail from PDF first page
  /// Returns image bytes or null on error
  static Future<Uint8List?> generateThumbnail(String pdfPath) async {
    PdfDocument? document;
    
    try {
      // Validate PDF file exists and is readable
      final file = File(pdfPath);
      if (!await file.exists()) {
        print('PDF file not found: $pdfPath');
        return null;
      }
      
      // Check file size - skip if too large (>50MB)
      final fileSize = await file.length();
      if (fileSize > 50 * 1024 * 1024) {
        print('PDF file too large for thumbnail: $pdfPath');
        return null;
      }
      
      // Check file extension
      if (!pdfPath.toLowerCase().endsWith('.pdf')) {
        print('Not a PDF file: $pdfPath');
        return null;
      }
      
      // Open PDF document with timeout
      document = await PdfDocument.openFile(pdfPath)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('PDF loading timed out'),
          );
      
      if (document.pages.isEmpty) {
        print('PDF has no pages: $pdfPath');
        return null;
      }

      // Get first page (0-indexed in pdfrx)
      final page = document.pages[0];
      
      // Render page to image with timeout
      final pageImage = await page.render(
        width: thumbnailWidth.toInt(),
        height: thumbnailHeight.toInt(),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('PDF rendering timed out'),
      );
      
      if (pageImage == null) {
        print('Failed to render PDF page: $pdfPath');
        return null;
      }

      // Convert to PNG bytes
      final image = await pageImage.createImage();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        print('Failed to convert image to bytes: $pdfPath');
        return null;
      }
      
      return byteData.buffer.asUint8List();

    } on TimeoutException catch (e) {
      print('Timeout generating thumbnail for $pdfPath: $e');
      return null;
    } catch (e, stackTrace) {
      print('Error generating thumbnail for $pdfPath: $e');
      print('Stack trace: $stackTrace');
      return null;
    } finally {
      // Always dispose document to prevent memory leaks
      try {
        await document?.dispose();
      } catch (e) {
        print('Error disposing PDF document: $e');
      }
    }
  }
  
  /// Get cached thumbnail path
  /// Returns path if exists, null otherwise
  static Future<String?> getCachedThumbnailPath(String bookId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/thumbnails/$bookId.png');
      return await file.exists() ? file.path : null;
    } catch (e) {
      return null;
    }
  }
  
  /// Save thumbnail to cache
  static Future<String?> saveThumbnail(String bookId, Uint8List bytes) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final thumbnailDir = Directory('${dir.path}/thumbnails');
      
      // Create thumbnails directory if not exists
      if (!await thumbnailDir.exists()) {
        await thumbnailDir.create(recursive: true);
      }
      
      // Save file
      final file = File('${thumbnailDir.path}/$bookId.png');
      await file.writeAsBytes(bytes);
      
      return file.path;
    } catch (e) {
      print('Error saving thumbnail: $e');
      return null;
    }
  }
  
  /// Get or generate thumbnail
  /// Returns cached path or generates new one
  static Future<String?> getThumbnail({
    required String bookId,
    required String pdfPath,
  }) async {
    // Check cache first
    final cached = await getCachedThumbnailPath(bookId);
    if (cached != null) {
      return cached;
    }
    
    // Generate new thumbnail
    final bytes = await generateThumbnail(pdfPath);
    if (bytes != null) {
      return await saveThumbnail(bookId, bytes);
    }
    
    return null;
  }
  
  /// Clear all cached thumbnails
  static Future<void> clearCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final thumbnailDir = Directory('${dir.path}/thumbnails');
      
      if (await thumbnailDir.exists()) {
        await thumbnailDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
  
  /// Delete specific thumbnail
  static Future<void> deleteThumbnail(String bookId) async {
    try {
      final path = await getCachedThumbnailPath(bookId);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error deleting thumbnail: $e');
    }
  }
}

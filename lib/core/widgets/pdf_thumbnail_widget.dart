import 'dart:io';
import 'package:flutter/material.dart';
import '../services/pdf_thumbnail_service.dart';

/// PDF Thumbnail Widget
/// 
/// Displays PDF first page as thumbnail with loading and error states
class PdfThumbnailWidget extends StatelessWidget {
  final String pdfPath;
  final String bookId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  
  const PdfThumbnailWidget({
    super.key,
    required this.pdfPath,
    required this.bookId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: PdfThumbnailService.getThumbnail(
        bookId: bookId,
        pdfPath: pdfPath,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading(context);
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return _buildThumbnail(snapshot.data!);
        }
        
        return _buildPlaceholder(context);
      },
    );
  }
  
  Widget _buildThumbnail(String imagePath) {
    final image = Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
    );
    
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }
    
    return image;
  }
  
  Widget _buildLoading(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(
              isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.picture_as_pdf,
          size: (height ?? 100) * 0.4,
          color: Colors.blue[700],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../data/models/book.dart';

/// RecentBookItem - Horizontal card for recent books
class RecentBookItem extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const RecentBookItem({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PDF Icon placeholder
              Container(
                height: 100,
                color: Colors.grey[200],
                child: Center(
                  child: Icon(
                    Icons.picture_as_pdf,
                    size: 48,
                    color: Colors.red[300],
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Progress bar
                    LinearProgressIndicator(
                      value: book.readingProgress / 100,
                      backgroundColor: Colors.grey[300],
                      minHeight: 4,
                    ),
                    const SizedBox(height: 4),
                    
                    // Progress text
                    Text(
                      '${book.readingProgress.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
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
  }
}

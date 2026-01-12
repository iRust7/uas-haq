import 'package:flutter/material.dart';

/// AboutScreen - App information and credits
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Icon
          Center(
            child: Icon(
              Icons.library_books,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // App Name
          Center(
            child: Text(
              'Book Library',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Version
          Center(
            child: Text(
              'Version 1.0.0 - ROADMAP 2',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Description
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Offline Book Library & PDF Reader is a comprehensive mobile application '
                    'for managing and reading PDF books. Features include:\n\n'
                    '• Import and organize PDF files\n'
                    '• Track reading progress\n'
                    '• Bookmark important pages\n'
                    '• Share book recommendations\n'
                    '• Guest mode and user accounts',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Developer Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Developer',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Created for UAS Mobile Programming'),
                  const Text('2026'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Technologies
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Built With',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildTechItem('Flutter', 'UI Framework'),
                  _buildTechItem('Hive', 'Local Database'),
                  _buildTechItem('flutter_pdfview', 'PDF Rendering'),
                  _buildTechItem('file_picker', 'File Selection'),
                  _buildTechItem('url_launcher', 'Sharing'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Copyright
          Center(
            child: Text(
              '© 2026 Book Library',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String name, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(
                    text: name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' - $description',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

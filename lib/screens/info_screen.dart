import 'package:flutter/material.dart';
import '../models/video_file.dart';
import '../theme/app_theme.dart';

class InfoScreen extends StatelessWidget {
  final VideoFile video;

  const InfoScreen({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معلومات الفيديو'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File icon header
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.movie,
                    color: AppTheme.orange, size: 56),
              ),
            ),
            const SizedBox(height: 20),

            // File name
            Center(
              child: Text(
                video.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Info cards
            _buildSection('معلومات الملف', [
              _buildRow(Icons.folder_outlined, 'المجلد', video.folder),
              _buildRow(Icons.storage, 'الحجم', video.formattedSize),
              _buildRow(Icons.calendar_today, 'التاريخ', video.formattedDate),
              _buildRow(Icons.code, 'الامتداد',
                  video.extension.toUpperCase()),
            ]),

            const SizedBox(height: 16),

            _buildSection('معلومات الفيديو', [
              _buildRow(Icons.timer, 'المدة', video.formattedDuration),
            ]),

            const SizedBox(height: 16),

            // Full path
            _buildSection('المسار الكامل', [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  video.path,
                  style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontFamily: 'monospace'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.orange,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

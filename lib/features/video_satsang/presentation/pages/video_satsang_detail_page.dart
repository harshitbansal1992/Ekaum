import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/video_satsang_item.dart';

class VideoSatsangDetailPage extends ConsumerWidget {
  const VideoSatsangDetailPage({super.key, required this.video});

  final VideoSatsangItem video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(video.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _openVideo(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      video.thumbnailUrl ?? video.thumbnailUrlDefault,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: AppTheme.primaryGold.withValues(alpha: 0.2),
                        child: const Icon(Icons.video_library, size: 64, color: AppTheme.primaryGold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 48),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              video.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
            ),
            if (video.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                video.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textDim),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openVideo(context),
              icon: const Icon(Icons.play_circle_fill),
              label: const Text('Watch on YouTube'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openVideo(BuildContext context) async {
    final uri = Uri.parse(video.youtubeWatchUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open video')),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/components/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/data/models/favourite_item.dart';
import '../../../home/presentation/providers/favourites_provider.dart';
import '../../data/models/video_satsang_item.dart';

class VideoSatsangListPage extends ConsumerStatefulWidget {
  const VideoSatsangListPage({super.key});

  @override
  ConsumerState<VideoSatsangListPage> createState() => _VideoSatsangListPageState();
}

class _VideoSatsangListPageState extends ConsumerState<VideoSatsangListPage> {
  List<VideoSatsangItem> _videos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getVideoSatsangList();
      final videos = data
          .map((item) => VideoSatsangItem.fromJson(item as Map<String, dynamic>))
          .toList();
      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.videoSatsang),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppTheme.textDim)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadVideos,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : _videos.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noVideoSatsangYet,
                        style: const TextStyle(color: AppTheme.textDim),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadVideos,
                      color: AppTheme.primaryGold,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _videos.length,
                        itemBuilder: (context, index) {
                          final video = _videos[index];
                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  video.thumbnailUrl ?? video.thumbnailUrlDefault,
                                  width: 80,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 80,
                                    height: 60,
                                    color: AppTheme.primaryGold.withValues(alpha: 0.2),
                                    child: const Icon(Icons.video_library, color: AppTheme.primaryGold),
                                  ),
                                ),
                              ),
                              title: Text(
                                video.title,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: video.description.isNotEmpty
                                  ? Text(
                                      video.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Consumer(
                                    builder: (_, ref, __) {
                                      final isFav = ref.watch(favouritesProvider).any((f) => f.type == 'video_satsang' && f.id == video.id);
                                      return IconButton(
                                        icon: Icon(
                                          isFav ? Icons.favorite : Icons.favorite_border,
                                          color: isFav ? Colors.red : AppTheme.textDim,
                                          size: 22,
                                        ),
                                        onPressed: () {
                                          final item = FavouriteItem(
                                            type: 'video_satsang',
                                            id: video.id,
                                            title: video.title,
                                            subtitle: video.description.isNotEmpty ? video.description : null,
                                            extra: video.toJson(),
                                          );
                                          ref.read(favouritesProvider.notifier).toggle(item);
                                        },
                                      );
                                    },
                                  ),
                                  const Icon(Icons.play_circle_fill, color: AppTheme.primaryGold),
                                ],
                              ),
                              onTap: () => context.push('/video-satsang/${video.id}', extra: video),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

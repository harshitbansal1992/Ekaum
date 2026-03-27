import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/components/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../avdhan/data/models/avdhan_audio.dart';
import '../../../patrika/data/models/patrika_issue.dart';
import '../../../video_satsang/data/models/video_satsang_item.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Map<String, dynamic> _results = {};
  bool _isSearching = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    final trimmed = q.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _results = {};
        _isSearching = false;
        _query = '';
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _query = trimmed;
    });
    final results = await ApiService.search(trimmed);
    if (mounted) {
      setState(() {
        _results = results;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.search),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGold),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (v) {
                if (v.trim().isEmpty) _search('');
              },
              onSubmitted: _search,
              textInputAction: TextInputAction.search,
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
                : _query.isEmpty
                    ? Center(
                        child: Text(
                          l10n.searchPrompt,
                          style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.textDim),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _buildResults(context, theme, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final avdhan = _results['avdhan'] as List<dynamic>? ?? [];
    final patrika = _results['patrika'] as List<dynamic>? ?? [];
    final samagam = _results['samagam'] as List<dynamic>? ?? [];
    final mantraNotes = _results['mantraNotes'] as List<dynamic>? ?? [];
    final announcements = _results['announcements'] as List<dynamic>? ?? [];
    final videoSatsang = _results['videoSatsang'] as List<dynamic>? ?? [];

    final total = avdhan.length + patrika.length + samagam.length + mantraNotes.length + announcements.length + videoSatsang.length;
    if (total == 0) {
      return Center(
        child: Text(
          l10n.noSearchResults,
          style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.textDim),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (avdhan.isNotEmpty) _sectionHeader(l10n.avdhan, Icons.headphones),
        ...avdhan.map((a) => _avdhanTile(context, a, theme)),
        if (patrika.isNotEmpty) _sectionHeader(l10n.patrika, Icons.menu_book),
        ...patrika.map((p) => _patrikaTile(context, p, theme)),
        if (samagam.isNotEmpty) _sectionHeader(l10n.samagam, Icons.event),
        ...samagam.map((s) => _samagamTile(context, s, theme)),
        if (mantraNotes.isNotEmpty) _sectionHeader(l10n.mantraNotes, Icons.note),
        ...mantraNotes.map((m) => _mantraNoteTile(context, m, theme)),
        if (announcements.isNotEmpty) _sectionHeader(l10n.visheshSandesh, Icons.campaign),
        ...announcements.map((a) => _announcementTile(context, a, theme)),
        if (videoSatsang.isNotEmpty) _sectionHeader(l10n.videoSatsang, Icons.video_library),
        ...videoSatsang.map((v) => _videoSatsangTile(context, v, theme)),
      ],
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.primaryGold,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avdhanTile(BuildContext context, dynamic a, ThemeData theme) {
    final id = a['id'] as String? ?? '';
    final title = a['title'] as String? ?? '';
    final audioUrl = a['audioUrl'] as String? ?? '';
    final audio = AvdhanAudio(
      id: id,
      title: title,
      description: a['description'] as String? ?? title,
      audioUrl: audioUrl,
      thumbnailUrl: a['thumbnailUrl'] as String?,
      createdAt: DateTime.now(),
      duration: a['duration'] as int? ?? 0,
    );
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.headphones, color: AppTheme.primaryGold),
        title: Text(title, style: theme.textTheme.titleSmall),
        trailing: const Icon(Icons.play_circle_fill, color: AppTheme.primaryGold),
        onTap: () => context.push('/avdhan/$id', extra: audio),
      ),
    );
  }

  Widget _patrikaTile(BuildContext context, dynamic p, ThemeData theme) {
    final issue = PatrikaIssue.fromJson(p as Map<String, dynamic>);
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.menu_book, color: AppTheme.primaryGold),
        title: Text(issue.title, style: theme.textTheme.titleSmall),
        subtitle: Text('${issue.month} ${issue.year}', style: theme.textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryGold),
        onTap: () => context.push('/patrika/${issue.id}', extra: issue),
      ),
    );
  }

  Widget _samagamTile(BuildContext context, dynamic s, ThemeData theme) {
    final id = s['id'];
    final title = s['title'] as String? ?? '';
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.event, color: AppTheme.primaryGold),
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: Text(s['location'] as String? ?? '', style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryGold),
        onTap: () => context.push('/samagam'),
      ),
    );
  }

  Widget _mantraNoteTile(BuildContext context, dynamic m, ThemeData theme) {
    final id = m['id']?.toString() ?? '';
    final heading = m['heading'] as String? ?? '';
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.note, color: AppTheme.primaryGold),
        title: Text(heading, style: theme.textTheme.titleSmall),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryGold),
        onTap: () => context.push('/mantra-notes/$id'),
      ),
    );
  }

  Widget _videoSatsangTile(BuildContext context, dynamic v, ThemeData theme) {
    final video = VideoSatsangItem.fromJson(v as Map<String, dynamic>);
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.video_library, color: AppTheme.primaryGold),
        title: Text(video.title, style: theme.textTheme.titleSmall),
        subtitle: video.description.isNotEmpty ? Text(video.description, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis) : null,
        trailing: const Icon(Icons.play_circle_fill, color: AppTheme.primaryGold),
        onTap: () => context.push('/video-satsang/${video.id}', extra: video),
      ),
    );
  }

  Widget _announcementTile(BuildContext context, dynamic a, ThemeData theme) {
    final title = a['title'] as String? ?? '';
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.campaign, color: AppTheme.primaryGold),
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: Text(a['description'] as String? ?? '', style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: () => context.push('/home'),
      ),
    );
  }
}

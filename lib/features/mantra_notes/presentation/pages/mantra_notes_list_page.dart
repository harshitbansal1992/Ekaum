import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/glass_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/mantra_note.dart';
import '../providers/mantra_notes_provider.dart';

class MantraNotesListPage extends ConsumerWidget {
  const MantraNotesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.mantraNotes),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(mantraNotesProvider);
          await ref.read(mantraNotesProvider.future);
        },
        color: AppTheme.primaryGold,
        child: ref.watch(mantraNotesProvider).when(
          data: (notes) => _buildNotesList(context, ref, theme, l10n, notes),
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                  const SizedBox(height: 16),
                  Text(err.toString(), textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(mantraNotesProvider),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/mantra-notes/new');
          if (context.mounted) ref.invalidate(mantraNotesProvider);
        },
        backgroundColor: AppTheme.primaryGold,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNotesList(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    List<MantraNote> notes,
  ) {
    if (notes.isEmpty) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.menu_book, size: 64, color: AppTheme.textDim),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noMantraNotesYet,
                      style: theme.textTheme.titleMedium?.copyWith(color: AppTheme.textDim),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.addMantraToStore,
                      style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await context.push('/mantra-notes/new');
                        if (context.mounted) ref.invalidate(mantraNotesProvider);
                      },
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addMantra),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
            onTap: () async {
              await context.push('/mantra-notes/${note.id}', extra: note);
              if (context.mounted) ref.invalidate(mantraNotesProvider);
            },
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.heading,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (note.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    note.description,
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textDim),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

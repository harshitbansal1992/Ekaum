import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/mantra_note.dart';

class MantraNoteFormPage extends ConsumerStatefulWidget {
  const MantraNoteFormPage({
    super.key,
    this.noteId,
    this.existingNote,
  });

  /// For new note: null. For edit: the note id.
  final String? noteId;

  /// Pre-filled note when editing (optional, can fetch by id)
  final MantraNote? existingNote;

  @override
  ConsumerState<MantraNoteFormPage> createState() => _MantraNoteFormPageState();
}

class _MantraNoteFormPageState extends ConsumerState<MantraNoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _headingController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _headingController = TextEditingController(text: widget.existingNote?.heading ?? '');
    _descriptionController = TextEditingController(text: widget.existingNote?.description ?? '');
    if (widget.noteId != null && widget.noteId != 'new' && widget.existingNote == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchNote());
    }
  }

  Future<void> _fetchNote() async {
    if (widget.noteId == null || widget.noteId == 'new') return;
    try {
      final data = await ApiService.getMantraNote(widget.noteId!);
      final note = MantraNote.fromJson(data);
      if (mounted) {
        _headingController.text = note.heading;
        _descriptionController.text = note.description;
      }
    } catch (_) {
      if (mounted) context.pop();
    }
  }

  @override
  void dispose() {
    _headingController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.noteId != null) {
        await ApiService.updateMantraNote(
          id: widget.noteId!,
          heading: _headingController.text.trim(),
          description: _descriptionController.text.trim(),
        );
      } else {
        await ApiService.createMantraNote(
          heading: _headingController.text.trim(),
          description: _descriptionController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.noteId != null
                  ? AppLocalizations.of(context)!.mantraNoteUpdated
                  : AppLocalizations.of(context)!.mantraNoteSaved,
            ),
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    if (widget.noteId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteMantraNote),
        content: Text(AppLocalizations.of(context)!.deleteMantraNoteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.deleteMantraNote(widget.noteId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.mantraNoteDeleted)),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.noteId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l10n.editMantraNote : l10n.addMantraNote),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
              onPressed: _isLoading ? null : _handleDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _headingController,
                  decoration: InputDecoration(
                    labelText: l10n.mantraHeading,
                    hintText: l10n.mantraHeadingHint,
                    prefixIcon: const Icon(Icons.title),
                  ),
                  maxLines: 1,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.headingRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.mantraDescription,
                    hintText: l10n.mantraDescriptionHint,
                    prefixIcon: const Icon(Icons.notes),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 6,
                  validator: (_) => null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

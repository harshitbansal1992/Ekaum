import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/components/glass_card.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/paath_form.dart';

class PaathDetailsPage extends ConsumerStatefulWidget {
  const PaathDetailsPage({super.key});

  @override
  ConsumerState<PaathDetailsPage> createState() => _PaathDetailsPageState();
}

class _PaathDetailsPageState extends ConsumerState<PaathDetailsPage> {
  List<PaathForm>? _forms;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  Future<void> _loadForms() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userId = ref.read(authProvider).user?.id;
      if (userId == null) throw Exception('Not logged in');
      final data = await ApiService.getPaathForms(userId);
      final forms = data
          .map((e) => PaathForm.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) {
        setState(() {
          _forms = forms;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Paath Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadForms,
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadForms,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_forms == null || _forms!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.volunteer_activism, size: 64, color: AppTheme.textDim),
              const SizedBox(height: 16),
              Text(
                'No paath forms yet',
                style: theme.textTheme.titleMedium?.copyWith(color: AppTheme.textDim),
              ),
              const SizedBox(height: 8),
              Text(
                'Book a paath service to see your details here',
                style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _forms!.length,
      itemBuilder: (context, index) {
        final form = _forms![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            onTap: () => context.push('/paath-details/${form.id}'),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        form.serviceName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _PaymentBadge(status: form.paymentStatus),
                        const SizedBox(width: 8),
                        _PaathStatusBadge(status: form.paathStatus),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  form.name,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textDim),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${NumberFormat.compact().format(form.totalAmount)} • ${form.installments} installment${form.installments > 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
                ),
                if (form.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Created ${DateFormat('MMM d, y').format(DateTime.parse(form.createdAt!))}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textDim,
                      fontSize: 12,
                    ),
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

class _PaymentBadge extends StatelessWidget {
  final String status;

  const _PaymentBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'completed' => (Colors.green, 'Paid'),
      'partial' => (Colors.blue, 'Partial'),
      _ => (Colors.orange, 'Pending'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _PaathStatusBadge extends StatelessWidget {
  final String status;

  const _PaathStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = status == 'done'
        ? (AppTheme.primaryGold, 'Done')
        : (AppTheme.textDim, 'Pending');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

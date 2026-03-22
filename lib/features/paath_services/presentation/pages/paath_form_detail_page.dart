import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/components/glass_card.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/paath_form.dart';

class PaathFormDetailPage extends ConsumerStatefulWidget {
  final String formId;

  const PaathFormDetailPage({super.key, required this.formId});

  @override
  ConsumerState<PaathFormDetailPage> createState() => _PaathFormDetailPageState();
}

class _PaathFormDetailPageState extends ConsumerState<PaathFormDetailPage> {
  PaathForm? _form;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getPaathFormDetail(widget.formId);
      if (mounted) {
        setState(() {
          _form = PaathForm.fromJson(data);
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
        title: const Text('Paath Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDetail,
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
              ElevatedButton(onPressed: _loadDetail, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    final form = _form!;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryCard(theme, form),
          const SizedBox(height: 16),
          _buildPaathStatusCard(theme, form),
          const SizedBox(height: 16),
          _buildInstallmentsCard(theme, form),
          if (form.familyMembers != null && form.familyMembers!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildFamilyCard(theme, form),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, PaathForm form) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            form.serviceName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGold,
            ),
          ),
          const SizedBox(height: 8),
          _row(theme, 'Name', form.name),
          _row(theme, 'Total Amount', '₹${NumberFormat('#,##0').format(form.totalAmount)}'),
          _row(theme, 'Payment Status', form.paymentStatusLabel),
        ],
      ),
    );
  }

  Widget _buildPaathStatusCard(ThemeData theme, PaathForm form) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppTheme.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Paath Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: form.paathStatus == 'done'
                      ? AppTheme.primaryGold.withOpacity(0.2)
                      : AppTheme.textDim.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  form.paathStatusLabel,
                  style: TextStyle(
                    color: form.paathStatus == 'done'
                        ? AppTheme.primaryGold
                        : AppTheme.textDim,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (form.paathDoneDate != null) ...[
                const SizedBox(width: 12),
                Text(
                  'Completed on ${form.paathDoneDate}',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentsCard(ThemeData theme, PaathForm form) {
    final details = form.installmentDetails ?? [];
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payment, color: AppTheme.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Installments (${details.length} × ₹${NumberFormat('#,##0').format(form.installmentAmount)})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (details.isEmpty)
            Text(
              'No installment records yet.',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textDim),
            )
          else
            ...details.map((inst) => _buildInstallmentRow(theme, inst)),
        ],
      ),
    );
  }

  Widget _buildInstallmentRow(ThemeData theme, PaathInstallment inst) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${inst.installmentNumber}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textDim,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              inst.amount != null
                  ? '₹${NumberFormat('#,##0').format(inst.amount)}'
                  : '-',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textDark),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: inst.isPaid
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              inst.isPaid ? 'Paid' : 'Pending',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: inst.isPaid ? Colors.green.shade700 : Colors.orange.shade700,
              ),
            ),
          ),
          if (inst.paymentDate != null) ...[
            const SizedBox(width: 8),
            Text(
              DateFormat('MMM d').format(DateTime.parse(inst.paymentDate!)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textDim,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFamilyCard(ThemeData theme, PaathForm form) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.family_restroom, color: AppTheme.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Family Members',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...form.familyMembers!.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${m.name}${m.relationship != null ? ' (${m.relationship})' : ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textDark),
                ),
              )),
        ],
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textDim),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }
}

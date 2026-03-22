import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/components/glass_card.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/payment_handler.dart';
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
  final TextEditingController _customAmountController = TextEditingController();
  bool _showCustomAmountField = false;
  String? _customAmountError;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
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
          _buildPaymentHistoryCard(theme, form),
          if (form.paymentStatus != 'completed') ...[
            const SizedBox(height: 16),
            _buildNextInstallmentCard(theme, form),
          ],
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
          _row(theme, 'Total Amount', '₹${NumberFormat('#,##0.##').format(form.totalAmount)}'),
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
    final pendingDetails = details.where((inst) => !inst.isPaid).toList();
    final paymentHistory = form.paymentHistory ?? [];
    final paidAmount = paymentHistory.fold<double>(0, (sum, payment) => sum + payment.amount);
    final pendingAmount = pendingDetails.fold<double>(0, (sum, inst) => sum + (inst.amount ?? 0));

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
                'Installment Details',
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
              Expanded(
                child: _buildInstallmentSummaryChip(
                  theme,
                  label: 'Paid by user',
                  value: '₹${NumberFormat('#,##0.##').format(paidAmount)}',
                  subtitle: '${paymentHistory.length} payment${paymentHistory.length == 1 ? '' : 's'} recorded',
                  backgroundColor: const Color(0xFFEAFBF1),
                  accentColor: Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInstallmentSummaryChip(
                  theme,
                  label: 'Remaining',
                  value: '₹${NumberFormat('#,##0.##').format(pendingAmount)}',
                  subtitle: '${pendingDetails.length} installment${pendingDetails.length == 1 ? '' : 's'} left',
                  backgroundColor: const Color(0xFFFFF6E8),
                  accentColor: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (details.isEmpty)
            Text(
              'No installment records yet.',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textDim),
            )
          else ...[
            if (pendingDetails.isNotEmpty) ...[
              Text(
                'Remaining installments',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ...pendingDetails.map((inst) => _buildInstallmentRow(theme, inst)),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryCard(ThemeData theme, PaathForm form) {
    final paymentHistory = form.paymentHistory ?? [];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: AppTheme.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Payment Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (paymentHistory.isEmpty)
            Text(
              'No payments found in records yet.',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textDim),
            )
          else ...paymentHistory.map((payment) => _buildPaymentRecordRow(theme, payment)),
        ],
      ),
    );
  }

  Widget _buildInstallmentSummaryChip(
    ThemeData theme, {
    required String label,
    required String value,
    required String subtitle,
    required Color backgroundColor,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
          ),
        ],
      ),
    );
  }

  _NextInstallment? _getNextInstallment(PaathForm form) {
    final byNumber = <int, PaathInstallment>{
      for (final i in (form.installmentDetails ?? const <PaathInstallment>[]))
        i.installmentNumber: i,
    };

    for (var number = 1; number <= form.installments; number++) {
      final current = byNumber[number];
      if (current?.isPaid == true) continue;
      return _NextInstallment(
        number: number,
        amount: current?.amount ?? form.installmentAmount,
      );
    }

    return null;
  }

  Widget _buildNextInstallmentCard(ThemeData theme, PaathForm form) {
    final next = _getNextInstallment(form);
    if (next == null) {
      return const SizedBox.shrink();
    }

    final pending = (form.installmentDetails ?? const <PaathInstallment>[])
      .where((i) => !i.isPaid)
      .toList();
    final remainingInstallments = pending.isNotEmpty
      ? pending.length
      : (form.installments - next.number + 1);
    final remainingAmount = pending.isNotEmpty
      ? pending.fold<double>(0, (sum, i) => sum + (i.amount ?? 0))
      : (next.amount * remainingInstallments);
    final suggestedAmount = next.amount <= 0 ? remainingAmount : next.amount;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_outlined, color: AppTheme.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pay Next Installment',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Installment #${next.number} • Suggested ₹${NumberFormat('#,##0.##').format(suggestedAmount)}',
            style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textDim),
          ),
          const SizedBox(height: 4),
          Text(
            'Remaining: $remainingInstallments installment${remainingInstallments > 1 ? 's' : ''} • ₹${NumberFormat('#,##0.##').format(remainingAmount)}',
            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
          ),
          const SizedBox(height: 4),
          Text(
            'You can pay the suggested amount or choose your own amount for this installment.',
            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await PaymentHandler.handlePaathPayment(
                      context,
                      form.id,
                      suggestedAmount,
                      next.number,
                    );
                    if (mounted) {
                      await _loadDetail();
                    }
                  },
                  icon: const Icon(Icons.payment),
                  label: Text('Pay #${next.number}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    setState(() {
                      _showCustomAmountField = !_showCustomAmountField;
                      _customAmountError = null;
                      if (_showCustomAmountField) {
                        _customAmountController.text = NumberFormat('0.##').format(suggestedAmount);
                      }
                    });
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Choose Amount'),
                ),
              ),
            ],
          ),
          if (_showCustomAmountField) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _customAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Custom amount',
                prefixText: '₹ ',
                errorText: _customAmountError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final input = _customAmountController.text.trim().replaceAll(',', '');
                  final amount = double.tryParse(input);

                  if (amount == null || amount <= 0) {
                    setState(() {
                      _customAmountError = 'Enter a valid amount';
                    });
                    return;
                  }

                  if (amount > remainingAmount) {
                    setState(() {
                      _customAmountError = 'Amount cannot exceed remaining balance';
                    });
                    return;
                  }

                  setState(() {
                    _customAmountError = null;
                  });

                  await PaymentHandler.handlePaathPayment(
                    context,
                    form.id,
                    amount,
                    next.number,
                  );
                  if (mounted) {
                    setState(() {
                      _showCustomAmountField = false;
                    });
                    await _loadDetail();
                  }
                },
                icon: const Icon(Icons.payment),
                label: const Text('Pay Custom Amount'),
              ),
            ),
          ],
          if (remainingInstallments > 1) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await PaymentHandler.handlePaathPayment(
                    context,
                    form.id,
                    remainingAmount,
                    next.number,
                    payRemainingInFull: true,
                  );
                  if (mounted) {
                    await _loadDetail();
                  }
                },
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Pay Full Remaining'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstallmentRow(ThemeData theme, PaathInstallment inst) {
    final statusColor = inst.isPaid ? Colors.green.shade700 : Colors.orange.shade700;
    final backgroundColor = inst.isPaid
        ? const Color(0xFFF3FCF7)
        : const Color(0xFFFFFAF2);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${inst.installmentNumber}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inst.isPaid ? 'User paid' : 'Pending payment',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Installment #${inst.installmentNumber} • ${inst.amount != null ? '₹${NumberFormat('#,##0.##').format(inst.amount)}' : '-'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (inst.paymentDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Paid on ${DateFormat('dd MMM yyyy').format(DateTime.parse(inst.paymentDate!).toLocal())}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textDim,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Text(
                    'Awaiting payment',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textDim,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              inst.isPaid ? 'Paid' : 'Pending',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRecordRow(ThemeData theme, PaathPaymentRecord payment) {
    final statusColor = payment.isCompleted ? Colors.green.shade700 : Colors.orange.shade700;
    final backgroundColor = payment.isCompleted
        ? const Color(0xFFF3FCF7)
        : const Color(0xFFFFFAF2);
    final dateValue = payment.completedAt ?? payment.createdAt;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.payment, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${NumberFormat('#,##0.##').format(payment.amount)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  payment.payRemainingInFull
                      ? 'Full remaining amount paid'
                      : 'Installment #${payment.installmentNumber ?? '-'} paid',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Payment ID: ${payment.paymentId}',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
                ),
                if (dateValue != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Recorded on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(dateValue).toLocal())}',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              payment.isCompleted ? 'Paid' : payment.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
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

class _NextInstallment {
  final int number;
  final double amount;

  const _NextInstallment({required this.number, required this.amount});
}

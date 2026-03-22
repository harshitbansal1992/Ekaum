import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_service.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/payment_handler.dart';
import '../../../../core/utils/validators.dart';

class DonationPage extends ConsumerStatefulWidget {
  const DonationPage({super.key});

  @override
  ConsumerState<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends ConsumerState<DonationPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;
  bool _isRecurring = false;
  String _frequency = 'monthly'; // monthly | yearly

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final amount = double.parse(_amountController.text);
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;
      
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Save donation record (creates pending, returns donationId)
      final data = await ApiService.createDonation(
        amount,
        isRecurring: _isRecurring,
        frequency: _frequency,
      );
      final donationId = data['donationId'] as String;

      if (mounted) {
        PaymentHandler.handleDonationPayment(
          context,
          amount,
          donationId,
          _nameController.text.trim(),
          _emailController.text.trim(),
          _phoneController.text.trim(),
          isRecurring: _isRecurring,
          frequency: _frequency,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.favorite, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Support BSLND',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your donation helps us continue our spiritual work',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Donation Amount (₹) *',
                  prefixText: '₹ ',
                ),
                validator: Validators.validateAmount,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Make it recurring'),
                subtitle: const Text('Donate every month or year automatically'),
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v),
                activeThumbColor: Theme.of(context).colorScheme.primary,
              ),
              if (_isRecurring) ...[
                RadioListTile<String>(
                  title: const Text('Monthly'),
                  value: 'monthly',
                  groupValue: _frequency,
                  onChanged: (v) => setState(() => _frequency = v ?? 'monthly'),
                ),
                RadioListTile<String>(
                  title: const Text('Yearly'),
                  value: 'yearly',
                  groupValue: _frequency,
                  onChanged: (v) => setState(() => _frequency = v ?? 'yearly'),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                ),
                validator: (value) =>
                    Validators.validateRequired(value, 'Name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                ),
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                ),
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Message (Optional)',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitDonation,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Proceed to Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


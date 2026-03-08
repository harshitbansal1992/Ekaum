import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_service.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/payment_service.dart';
import '../../../avdhan/presentation/providers/subscription_provider.dart';

class PaymentStatusPage extends ConsumerStatefulWidget {
  final String paymentType;
  final String? paymentId;
  final String? status;

  const PaymentStatusPage({
    super.key,
    required this.paymentType,
    this.paymentId,
    this.status,
  });

  @override
  ConsumerState<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends ConsumerState<PaymentStatusPage> {
  bool _isVerifying = true;
  bool _isSuccess = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _verifyPayment();
  }

  Future<void> _verifyPayment() async {
    if (widget.paymentId == null) {
      setState(() {
        _isVerifying = false;
        _isSuccess = false;
        _message = 'Payment ID not found';
      });
      return;
    }

    try {
      // Verify payment with Instamojo
      final result = await PaymentService.verifyPayment(widget.paymentId!);
      
      final paymentRequest = result['payment_request'];
      final payments = paymentRequest['payments'] as List?;
      
      if (payments != null && payments.isNotEmpty) {
        final payment = payments.first;
        final status = payment['status'] as String?;
        
        if (status == 'Credit' || status == 'Completed') {
          // Update database based on payment type
          await _updatePaymentStatus(true);
          
          setState(() {
            _isVerifying = false;
            _isSuccess = true;
            _message = 'Payment successful!';
          });

          // Refresh subscription status if it was a subscription payment
          if (widget.paymentType == 'subscription') {
            ref.invalidate(subscriptionProvider);
          }
        } else {
          setState(() {
            _isVerifying = false;
            _isSuccess = false;
            _message = 'Payment failed or pending';
          });
        }
      } else {
        setState(() {
          _isVerifying = false;
          _isSuccess = false;
          _message = 'Payment not found';
        });
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _isSuccess = false;
        _message = 'Error verifying payment: ${e.toString()}';
      });
    }
  }

  Future<void> _updatePaymentStatus(bool success) async {
    final authState = ref.read(authProvider);
    final userId = authState.user?.id;
    if (userId == null) return;

    try {
      // Payment status is now handled by the backend webhook
      // This method is kept for compatibility but the backend handles updates
      // The webhook will update subscriptions, purchases, etc. automatically
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Status'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isVerifying)
                const CircularProgressIndicator()
              else
                Icon(
                  _isSuccess ? Icons.check_circle : Icons.error,
                  size: 80,
                  color: _isSuccess ? Colors.green : Colors.red,
                ),
              const SizedBox(height: 24),
              Text(
                _isVerifying
                    ? 'Verifying Payment...'
                    : _isSuccess
                        ? 'Payment Successful!'
                        : 'Payment Failed',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_isSuccess) {
                    // Navigate based on payment type
                    switch (widget.paymentType) {
                      case 'subscription':
                        context.go('/avdhan');
                        break;
                      case 'patrika':
                        context.go('/patrika');
                        break;
                      case 'paath':
                        context.go('/paath-services');
                        break;
                      case 'donation':
                        context.go('/home');
                        break;
                      default:
                        context.go('/home');
                    }
                  } else {
                    context.go('/home');
                  }
                },
                child: Text(_isSuccess ? 'Continue' : 'Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


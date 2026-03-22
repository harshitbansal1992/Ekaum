import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/avdhan/presentation/providers/subscription_provider.dart';

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
  bool _isVerifying = false;
  bool _isSuccess = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _evaluateStatus();
  }

  void _evaluateStatus() {
    // With Razorpay in-app checkout, we navigate here after verification
    // status=Credit or status=Credit means success (Razorpay uses 'captured')
    final status = widget.status?.toLowerCase();
    final isSuccess =
        status == 'credit' || status == 'completed' || status == 'captured';

    setState(() {
      _isVerifying = false;
      _isSuccess = isSuccess && widget.paymentId != null;
      _message = _isSuccess ? 'Payment successful!' : 'Payment failed or cancelled';
    });

    if (_isSuccess && widget.paymentType == 'subscription') {
      ref.invalidate(subscriptionProvider);
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
                    switch (widget.paymentType) {
                      case 'subscription':
                        context.go('/avdhan');
                        break;
                      case 'patrika':
                        context.go('/patrika');
                        break;
                      case 'paath':
                        context.go('/paath-details');
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

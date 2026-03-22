import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/payment_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/avdhan/presentation/providers/subscription_provider.dart';

class PaymentHandler {
  // Handle subscription payment - opens Razorpay checkout in-app
  static Future<void> handleSubscriptionPayment(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final authState = ref.read(authProvider);
    final user = authState.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    try {
      final payment = await PaymentService.createSubscriptionPayment(
        userId: user.id,
        email: user.email,
        phone: user.phone ?? '',
        name: user.name ?? 'User',
      );

      if (context.mounted && payment['success'] == true) {
        ref.invalidate(subscriptionProvider);
        context.go('/payment/subscription?payment_id=${payment['paymentId']}&payment_status=Credit');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment error: ${e.toString()}')),
        );
      }
    }
  }

  // Handle patrika payment - opens Razorpay checkout in-app
  static Future<void> handlePatrikaPayment(
    BuildContext context,
    String issueId,
    double amount,
  ) async {
    final authState = ProviderScope.containerOf(context).read(authProvider);
    final user = authState.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    try {
      final payment = await PaymentService.createPatrikaPayment(
        userId: user.id,
        issueId: issueId,
        amount: amount,
        email: user.email,
        phone: user.phone ?? '',
        name: user.name ?? 'User',
      );

      if (context.mounted && payment['success'] == true) {
        context.go('/payment/patrika?payment_id=${payment['paymentId']}&payment_status=Credit');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment error: ${e.toString()}')),
        );
      }
    }
  }

  // Handle paath service payment - opens Razorpay checkout in-app
  static Future<void> handlePaathPayment(
    BuildContext context,
    String formId,
    double amount,
    int installmentNumber, {
    bool payRemainingInFull = false,
    bool goToMyPaathOnSuccess = false,
  }
  ) async {
    final authState = ProviderScope.containerOf(context).read(authProvider);
    final user = authState.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    try {
      final payment = await PaymentService.createPaathPayment(
        userId: user.id,
        formId: formId,
        amount: amount,
        installmentNumber: installmentNumber,
        payRemainingInFull: payRemainingInFull,
        email: user.email,
        phone: user.phone ?? '',
        name: user.name ?? 'User',
      );

      if (context.mounted && payment['success'] == true) {
        if (goToMyPaathOnSuccess) {
          context.go('/paath-details');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Installment payment successful')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment error: ${e.toString()}')),
        );
      }
    }
  }

  // Handle donation payment - opens Razorpay checkout in-app
  static Future<void> handleDonationPayment(
    BuildContext context,
    double amount,
    String donationId,
    String name,
    String email,
    String phone, {
    bool isRecurring = false,
    String frequency = 'monthly',
  }) async {
    final authState = ProviderScope.containerOf(context).read(authProvider);
    final user = authState.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    try {
      final payment = await PaymentService.createDonationPayment(
        userId: user.id,
        donationId: donationId,
        amount: amount,
        email: email,
        phone: phone,
        name: name,
        isRecurring: isRecurring,
        frequency: frequency,
      );

      if (context.mounted && payment['success'] == true) {
        context.go('/payment/donation?payment_id=${payment['paymentId']}&payment_status=Credit');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment error: ${e.toString()}')),
        );
      }
    }
  }
}


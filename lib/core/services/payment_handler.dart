import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/payment_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class PaymentHandler {
  // Handle subscription payment
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

      if (payment['success'] == true) {
        await PaymentService.launchPayment(payment['paymentUrl']);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment error: ${e.toString()}')),
        );
      }
    }
  }

  // Handle patrika payment
  static Future<void> handlePatrikaPayment(
    BuildContext context,
    String issueId,
    double amount,
  ) async {
    // Get user from auth provider via context
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

      if (payment['success'] == true) {
        await PaymentService.launchPayment(payment['paymentUrl']);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment error: ${e.toString()}')),
        );
      }
    }
  }

  // Handle paath service payment
  static Future<void> handlePaathPayment(
    BuildContext context,
    String formId,
    double amount,
    int installmentNumber,
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
        email: user.email,
        phone: user.phone ?? '',
        name: user.name ?? 'User',
      );

      if (payment['success'] == true) {
        await PaymentService.launchPayment(payment['paymentUrl']);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment error: ${e.toString()}')),
        );
      }
    }
  }

  // Handle donation payment
  static Future<void> handleDonationPayment(
    BuildContext context,
    double amount,
    String name,
    String email,
    String phone,
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
      final payment = await PaymentService.createDonationPayment(
        userId: user.id,
        amount: amount,
        email: email,
        phone: phone,
        name: name,
      );

      if (payment['success'] == true) {
        await PaymentService.launchPayment(payment['paymentUrl']);
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


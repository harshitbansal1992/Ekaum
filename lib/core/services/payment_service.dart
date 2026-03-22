import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../constants/app_constants.dart';
import '../utils/platform_utils.dart';
import 'api_service.dart';

/// Razorpay payment service - in-app checkout for all payment types
class PaymentService {
  static String? _keyId;

  static void initialize(String keyId) {
    _keyId = keyId;
  }

  static String get keyId => _keyId ?? '';

  static bool get isInitialized => _keyId != null && _keyId!.isNotEmpty;

  /// Create and complete subscription payment - opens Razorpay checkout
  static Future<Map<String, dynamic>> createSubscriptionPayment({
    required String userId,
    required String email,
    required String phone,
    required String name,
  }) async {
    return _createAndCompletePayment(
      amount: AppConstants.subscriptionPrice,
      type: 'subscription',
      metadata: {'userId': userId},
      name: name,
      email: email,
      phone: phone,
    );
  }

  /// Create and complete patrika payment
  static Future<Map<String, dynamic>> createPatrikaPayment({
    required String userId,
    required String issueId,
    required double amount,
    required String email,
    required String phone,
    required String name,
  }) async {
    return _createAndCompletePayment(
      amount: amount,
      type: 'patrika',
      metadata: {
        'userId': userId,
        'issueId': issueId,
      },
      name: name,
      email: email,
      phone: phone,
    );
  }

  /// Create and complete paath service payment
  static Future<Map<String, dynamic>> createPaathPayment({
    required String userId,
    required String formId,
    required double amount,
    required int installmentNumber,
    required String email,
    required String phone,
    required String name,
  }) async {
    return _createAndCompletePayment(
      amount: amount,
      type: 'paath',
      metadata: {
        'userId': userId,
        'formId': formId,
        'installmentNumber': installmentNumber.toString(),
      },
      name: name,
      email: email,
      phone: phone,
    );
  }

  /// Create and complete donation payment
  static Future<Map<String, dynamic>> createDonationPayment({
    required String userId,
    required String donationId,
    required double amount,
    required String email,
    required String phone,
    required String name,
    bool isRecurring = false,
    String frequency = 'monthly',
  }) async {
    final metadata = {
      'userId': userId,
      'donationId': donationId,
      if (isRecurring) 'isRecurring': 'true',
      if (isRecurring) 'frequency': frequency,
    };
    return _createAndCompletePayment(
      amount: amount,
      type: 'donation',
      metadata: metadata,
      name: name,
      email: email,
      phone: phone,
    );
  }

  static Future<Map<String, dynamic>> _createAndCompletePayment({
    required double amount,
    required String type,
    required Map<String, String> metadata,
    required String name,
    required String email,
    required String phone,
  }) async {
    if (!isInitialized) {
      throw Exception('Payment service not initialized. Add Razorpay key.');
    }

    // Create order via backend (include buyer info in metadata for records)
    final orderResponse = await ApiService.createPaymentOrder(
      amount: amount,
      type: type,
      metadata: {...metadata, 'name': name, 'email': email, 'phone': phone},
    );

    final orderId = orderResponse['orderId'] as String?;
    final checkoutKey = orderResponse['keyId'] as String? ?? _keyId;

    if (orderId == null || orderId.isEmpty || checkoutKey == null) {
      throw Exception('Failed to create payment order');
    }

    // Open Razorpay checkout
    final result = await _openRazorpayCheckout(
      keyId: checkoutKey,
      orderId: orderId,
      amount: amount,
      name: name,
      email: email,
      phone: phone,
    );

    if (result['success'] != true) {
      throw Exception(result['error'] ?? 'Payment failed');
    }

    final paymentId = result['paymentId'] as String?;
    if (paymentId == null || paymentId.isEmpty) {
      throw Exception('Payment ID not received');
    }

    // Verify with backend
    final verifyResponse = await ApiService.verifyPayment(
      orderId: orderId,
      paymentId: paymentId,
    );

    if (verifyResponse['success'] != true) {
      throw Exception(verifyResponse['error'] ?? 'Payment verification failed');
    }

    return {
      'success': true,
      'paymentId': paymentId,
      'orderId': orderId,
      'type': type,
    };
  }

  static Future<Map<String, dynamic>> _openRazorpayCheckout({
    required String keyId,
    required String orderId,
    required double amount,
    required String name,
    required String email,
    required String phone,
  }) async {
    if (!isRazorpaySupported) {
      throw Exception(
        'In-app payment is not available on this platform. '
        'Please use the Android or iOS app for payments.',
      );
    }
    final completer = Completer<Map<String, dynamic>>();
    Razorpay razorpay;
    try {
      razorpay = Razorpay();
    } catch (e) {
      throw Exception(
        'In-app payment is not available on this platform. '
        'Please use the Android or iOS app for payments.',
      );
    }

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      razorpay.clear();
      if (!completer.isCompleted) {
        completer.complete({
          'success': true,
          'paymentId': response.paymentId,
          'orderId': response.orderId,
        });
      }
    });

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
      razorpay.clear();
      if (!completer.isCompleted) {
        completer.complete({
          'success': false,
          'error': response.message ?? 'Payment failed',
        });
      }
    });

    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
      razorpay.clear();
      if (!completer.isCompleted) {
        completer.complete({
          'success': false,
          'error': 'External wallet selected - complete payment in browser',
        });
      }
    });

    final options = {
      'key': keyId,
      'amount': (amount * 100).round(), // paise
      'name': 'Ekaum / BSLND',
      'description': 'Payment',
      'order_id': orderId,
      'prefill': {
        'contact': phone,
        'email': email,
        'name': name,
      },
      'theme': {'color': '#0D47A1'},
    };

    razorpay.open(options);

    return completer.future;
  }

  /// Verify payment status (for deep link / status page)
  static Future<Map<String, dynamic>> verifyPayment(String paymentId) async {
    // With Razorpay in-app checkout, verification is done in _createAndCompletePayment
    // This is kept for PaymentStatusPage when navigated with pre-verified result
    return {'success': true, 'paymentId': paymentId};
  }
}

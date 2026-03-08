import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';
import '../config/app_config.dart';

class PaymentService {
  static const String instamojoApiUrl = 'https://www.instamojo.com/api/1.1/';
  static String? apiKey;
  static String? authToken;

  static void initialize(String key, String token) {
    apiKey = key;
    authToken = token;
  }

  // Create payment request for subscription
  static Future<Map<String, dynamic>> createSubscriptionPayment({
    required String userId,
    required String email,
    required String phone,
    required String name,
  }) async {
    return _createPayment(
      amount: AppConstants.subscriptionPrice,
      purpose: 'Avdhan Monthly Subscription',
      buyerName: name,
      email: email,
      phone: phone,
      redirectUrl: 'bslndapp://payment/subscription?payment_id={payment_id}&payment_status={payment_status}',
      webhook: AppConfig.backendUrl + '/api/payments/webhook',
      metadata: {
        'userId': userId,
        'type': 'subscription',
      },
    );
  }

  // Create payment request for patrika
  static Future<Map<String, dynamic>> createPatrikaPayment({
    required String userId,
    required String issueId,
    required double amount,
    required String email,
    required String phone,
    required String name,
  }) async {
    return _createPayment(
      amount: amount,
      purpose: 'Prabhu Kripa Patrika',
      buyerName: name,
      email: email,
      phone: phone,
      redirectUrl: 'bslndapp://payment/patrika?payment_id={payment_id}&payment_status={payment_status}',
      webhook: AppConfig.backendUrl + '/api/payments/webhook',
      metadata: {
        'userId': userId,
        'type': 'patrika',
        'issueId': issueId,
      },
    );
  }

  // Create payment request for paath service
  static Future<Map<String, dynamic>> createPaathPayment({
    required String userId,
    required String formId,
    required double amount,
    required int installmentNumber,
    required String email,
    required String phone,
    required String name,
  }) async {
    return _createPayment(
      amount: amount,
      purpose: 'Paath Service - Installment $installmentNumber',
      buyerName: name,
      email: email,
      phone: phone,
      redirectUrl: 'bslndapp://payment/paath?payment_id={payment_id}&payment_status={payment_status}',
      webhook: AppConfig.backendUrl + '/api/payments/webhook',
      metadata: {
        'userId': userId,
        'type': 'paath',
        'formId': formId,
        'installmentNumber': installmentNumber.toString(),
      },
    );
  }

  // Create payment request for donation
  static Future<Map<String, dynamic>> createDonationPayment({
    required String userId,
    required double amount,
    required String email,
    required String phone,
    required String name,
  }) async {
    return _createPayment(
      amount: amount,
      purpose: 'Donation to BSLND',
      buyerName: name,
      email: email,
      phone: phone,
      redirectUrl: 'bslndapp://payment/donation?payment_id={payment_id}&payment_status={payment_status}',
      webhook: AppConfig.backendUrl + '/api/payments/webhook',
      metadata: {
        'userId': userId,
        'type': 'donation',
      },
    );
  }

  static Future<Map<String, dynamic>> _createPayment({
    required double amount,
    required String purpose,
    required String buyerName,
    required String email,
    required String phone,
    required String redirectUrl,
    required String webhook,
    required Map<String, String> metadata,
  }) async {
    if (apiKey == null || authToken == null) {
      throw Exception('Payment service not initialized');
    }

    try {
      final dio = Dio();
      dio.options.headers = {
        'X-Api-Key': apiKey!,
        'X-Auth-Token': authToken!,
      };

      final response = await dio.post(
        '${instamojoApiUrl}payment-requests/',
        data: {
          'amount': amount.toStringAsFixed(2),
          'purpose': purpose,
          'buyer_name': buyerName,
          'email': email,
          'phone': phone,
          'redirect_url': redirectUrl,
          'webhook': webhook,
          'allow_repeated_payments': false,
          ...metadata.map((key, value) => MapEntry('metadata_$key', value)),
        },
      );

      if (response.statusCode == 201) {
        final paymentData = response.data['payment_request'];
        return {
          'success': true,
          'paymentId': paymentData['id'],
          'paymentUrl': paymentData['longurl'],
        };
      } else {
        throw Exception('Failed to create payment request');
      }
    } catch (e) {
      throw Exception('Payment error: ${e.toString()}');
    }
  }

  // Launch payment URL
  static Future<void> launchPayment(String paymentUrl) async {
    final uri = Uri.parse(paymentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch payment URL');
    }
  }

  // Verify payment status
  static Future<Map<String, dynamic>> verifyPayment(String paymentId) async {
    if (apiKey == null || authToken == null) {
      throw Exception('Payment service not initialized');
    }

    try {
      final dio = Dio();
      dio.options.headers = {
        'X-Api-Key': apiKey!,
        'X-Auth-Token': authToken!,
      };

      final response = await dio.get(
        '${instamojoApiUrl}payment-requests/$paymentId/',
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to verify payment');
      }
    } catch (e) {
      throw Exception('Payment verification error: ${e.toString()}');
    }
  }
}

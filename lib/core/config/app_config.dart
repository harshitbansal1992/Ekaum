// App Configuration
// Initialize payment service and other configurations here
//
// Production: flutter build apk --dart-define=BACKEND_URL=https://api.yourdomain.com/api
// Android emulator: flutter run --dart-define=BACKEND_URL=http://10.0.2.2:3000/api

import '../services/payment_service.dart';

class AppConfig {
  // Razorpay test credentials - replace with live keys for production
  static const String razorpayKeyId = 'rzp_test_STczlMNUcWRhnZ';
  // Note: key secret is used only on backend - never expose in app

  /// Backend API base URL (including /api). Set via --dart-define=BACKEND_URL=... for production.
  static String get backendApiBaseUrl =>
      const String.fromEnvironment(
        'BACKEND_URL',
        defaultValue: 'http://localhost:3000/api',
      );


  // Initialize payment service with Razorpay key (key ID only - secret stays on server)
  static void initializePayment() {
    PaymentService.initialize(razorpayKeyId);
  }
}

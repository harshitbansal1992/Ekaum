// App Configuration
// Initialize payment service and other configurations here

import '../services/payment_service.dart';

class AppConfig {
  // Initialize payment service with Instamojo credentials
  // Get these from: https://www.instamojo.com/developers/
  static void initializePayment() {
    // Payment service initialization
    // Get credentials from: https://www.instamojo.com/developers/
    // 
    // For development, you can leave placeholders - payment features will show
    // appropriate error messages when used without credentials
    final apiKey = const String.fromEnvironment(
      'INSTAMOJO_API_KEY',
      defaultValue: 'YOUR_INSTAMOJO_API_KEY',
    );
    final authToken = const String.fromEnvironment(
      'INSTAMOJO_AUTH_TOKEN',
      defaultValue: 'YOUR_INSTAMOJO_AUTH_TOKEN',
    );
    
    // Only initialize if credentials are provided
    if (apiKey != 'YOUR_INSTAMOJO_API_KEY' && authToken != 'YOUR_INSTAMOJO_AUTH_TOKEN') {
      PaymentService.initialize(apiKey, authToken);
    }
    // If credentials not set, payment service will throw helpful errors when used
  }

  // Backend API URL
  static const String backendUrl = 'https://your-backend-url.com';
  
  // Update webhook URLs in payment_service.dart to match your backend
}


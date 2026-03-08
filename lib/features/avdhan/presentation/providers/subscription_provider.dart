import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_service.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

final subscriptionProvider = FutureProvider<bool>((ref) async {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id;
  
  if (userId == null) return false;

  try {
    final subscription = await ApiService.getSubscription(userId);
    final isActive = subscription['isActive'] as bool? ?? false;
    
    if (!isActive) return false;

    final expiryDate = subscription['expiryDate'] as String?;
    if (expiryDate != null) {
      final expiry = DateTime.parse(expiryDate);
      return DateTime.now().isBefore(expiry);
    }

    return isActive;
  } catch (e) {
    return false;
  }
});

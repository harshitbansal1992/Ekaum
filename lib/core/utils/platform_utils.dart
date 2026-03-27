// Platform utilities for cross-platform support (iOS, Android, Windows, Web)

import 'package:flutter/foundation.dart';

/// Whether in-app Razorpay checkout is supported. Only Android and iOS support it.
bool get isRazorpaySupported {
  if (kIsWeb) return false;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      return true;
    default:
      return false; // Windows, macOS, Linux, Fuchsia
  }
}

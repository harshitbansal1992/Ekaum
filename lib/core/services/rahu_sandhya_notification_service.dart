// Rahu Kaal and Sandhya Kaal daily notification service.
// Schedules local notifications at the start of each period based on user location.

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/rahu_kaal/data/services/rahu_kaal_location_service.dart';
import '../../features/rahu_kaal/data/services/rahu_kaal_service.dart';

const _keyNotifyRahuKaal = 'notify_rahu_kaal';
const _keyNotifySandhyaKaal = 'notify_sandhya_kaal';

/// Notification IDs (must be unique)
const int _idRahuKaal = 1000;
const int _idPratahSandhya = 1001;
const int _idMadhyaSandhya = 1002;
const int _idSayahnaSandhya = 1003;

class RahuSandhyaNotificationService {
  RahuSandhyaNotificationService._();
  static final RahuSandhyaNotificationService _instance =
      RahuSandhyaNotificationService._();
  static RahuSandhyaNotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'rahu_sandhya_reminders',
    'Rahu Kaal & Sandhya Kaal',
    description: 'Daily reminders for Rahu Kaal and Sandhya Kaal periods',
    importance: Importance.defaultImportance,
  );

  /// Initialize the notification plugin. Call from main().
  Future<void> initialize() async {
    if (kIsWeb) return;
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    const initSettings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    try {
      tz_data.initializeTimeZones();
      final location = tz.getLocation('Asia/Kolkata');
      tz.setLocalLocation(location);
    } catch (e) {
      debugPrint('RahuSandhyaNotificationService: timezone init: $e');
    }

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Get stored preference for Rahu Kaal notifications.
  static Future<bool> getNotifyRahuKaal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifyRahuKaal) ?? false;
  }

  /// Get stored preference for Sandhya Kaal notifications.
  static Future<bool> getNotifySandhyaKaal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifySandhyaKaal) ?? false;
  }

  /// Request notification permission (Android 13+, iOS).
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted == true;
  }

  /// Set Rahu Kaal notification preference and reschedule.
  Future<void> setNotifyRahuKaal(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyRahuKaal, enabled);
    if (enabled) {
      await requestPermission();
      await rescheduleAll();
    } else {
      await _cancelRahuKaal();
    }
  }

  /// Set Sandhya Kaal notification preference and reschedule.
  Future<void> setNotifySandhyaKaal(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifySandhyaKaal, enabled);
    if (enabled) {
      await requestPermission();
      await rescheduleAll();
    } else {
      await _cancelSandhyaKaal();
    }
  }

  /// Reschedule all notifications based on current preferences and location.
  Future<void> rescheduleAll() async {
    if (kIsWeb) return;

    final rahuEnabled = await getNotifyRahuKaal();
    final sandhyaEnabled = await getNotifySandhyaKaal();
    if (!rahuEnabled && !sandhyaEnabled) return;

    RahuKaalLocationResult location;
    try {
      location = await RahuKaalLocationService.getCurrentLocation();
    } catch (e) {
      debugPrint('RahuSandhyaNotificationService: location error: $e');
      return;
    }

    final now = DateTime.now();
    for (int d = 0; d < 7; d++) {
      final date = DateTime(now.year, now.month, now.day).add(Duration(days: d));
      final times = RahuKaalService.getSchedulingTimes(
        latitude: location.latitude,
        longitude: location.longitude,
        date: date,
      );

      if (rahuEnabled) {
        await _scheduleNotification(
          id: _idRahuKaal + d * 10,
          scheduledTime: times['rahuKaal']!,
          title: 'Rahu Kaal',
          body: 'Rahu Kaal has started. Avoid starting new paath during this time.',
        );
      }

      if (sandhyaEnabled) {
        await _scheduleNotification(
          id: _idPratahSandhya + d * 10,
          scheduledTime: times['pratahSandhya']!,
          title: 'Pratah Sandhya',
          body: 'Morning Sandhya period has started.',
        );
        await _scheduleNotification(
          id: _idMadhyaSandhya + d * 10,
          scheduledTime: times['madhyaSandhya']!,
          title: 'Madhya Sandhya',
          body: 'Midday Sandhya period has started.',
        );
        await _scheduleNotification(
          id: _idSayahnaSandhya + d * 10,
          scheduledTime: times['sayahnaSandhya']!,
          title: 'Sayahna Sandhya',
          body: 'Evening Sandhya period has started.',
        );
      }
    }

    if (!rahuEnabled) await _cancelRahuKaal();
    if (!sandhyaEnabled) await _cancelSandhyaKaal();
  }

  Future<void> _scheduleNotification({
    required int id,
    required DateTime scheduledTime,
    required String title,
    required String body,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) return;

    final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'rahu_sandhya_reminders',
        'Rahu Kaal & Sandhya Kaal',
        channelDescription: 'Daily reminders for Rahu Kaal and Sandhya Kaal',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _cancelRahuKaal() async {
    for (int d = 0; d < 7; d++) {
      await _plugin.cancel(_idRahuKaal + d * 10);
    }
  }

  Future<void> _cancelSandhyaKaal() async {
    for (int d = 0; d < 7; d++) {
      await _plugin.cancel(_idPratahSandhya + d * 10);
      await _plugin.cancel(_idMadhyaSandhya + d * 10);
      await _plugin.cancel(_idSayahnaSandhya + d * 10);
    }
  }
}

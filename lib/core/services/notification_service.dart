import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService with WidgetsBindingObserver {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<NotificationService> init() async {
    tz.initializeTimeZones();
    final dynamic timeZone = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timeZone is String ? timeZone : timeZone.identifier;
    String effectiveTimeZoneName = timeZoneName;
    if (effectiveTimeZoneName == 'Asia/Calcutta') {
      effectiveTimeZoneName = 'Asia/Kolkata';
    }

    try {
      tz.setLocalLocation(tz.getLocation(effectiveTimeZoneName));
      print('Timezone set to: $effectiveTimeZoneName');
    } catch (e) {
      print('Warning: Could not set timezone $effectiveTimeZoneName, falling back to UTC. Error: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);
    
    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    
    // Request permissions for Android 13+
    await requestPermissions();

    return this;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed - checking permissions...');
      requestPermissions();
    }
  }

  Future<void> requestPermissions() async {
    // Request notifications permission for Android 13+
    await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    
    // Check and request exact alarm permission for Android 12+
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final bool? hasPermission = await androidImplementation.canScheduleExactNotifications();
      if (hasPermission == false) {
        print('Exact alarm permission not granted. Requesting...');
        await androidImplementation.requestExactAlarmsPermission();
      } else {
        print('Exact alarm permission already granted.');
      }
    }
  }

  Future<bool> isExactAlarmPermissionGranted() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      return await androidImplementation.canScheduleExactNotifications() ?? false;
    }
    return true; // Not Android or not available
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    print('Scheduling notification: $title');
    print('  - Requested Local Time: $scheduledDate');
    print('  - Current Local Time: ${DateTime.now()}');
    
    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
    print('  - System TZ: ${tz.local.name}');
    print('  - Scheduled TZ Time: $scheduledTZ');

    // Ensure we don't schedule in the past
    if (scheduledTZ.isBefore(tz.TZDateTime.now(tz.local))) {
      print('Warning: Cannot schedule in the past (TZ interpretation)');
      return;
    }

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'prep_reminder',
            'Interview Prep Reminders',
            channelDescription: 'Notifications for your scheduled interview practice',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'Interview Prep Time!',
            channelShowBadge: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Notification scheduled successfully for $id');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Channel',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    final NotificationDetails details = NotificationDetails(android: androidDetails);
    await _notifications.show(id, title, body, details);
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_model.dart';
import '../models/settings_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // macOS initialization settings
    const DarwinInitializationSettings macOSSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macOSSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    _initialized = true;
    print('✅ Notification service initialized');
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    print('📱 Requesting notification permissions...');

    // iOS/macOS permissions
    final iosGranted = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    final macosGranted = await _notifications
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Android 13+ permissions
    final androidGranted = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final granted = iosGranted ?? macosGranted ?? androidGranted ?? false;

    if (granted) {
      print('✅ Notification permissions granted!');
    } else {
      print('⚠️ Notification permissions denied or not applicable');
    }

    return granted;
  }

  /// Check if notification permissions are granted
  Future<bool> areNotificationsEnabled() async {
    // Check iOS permissions
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    // Check macOS permissions
    final macosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();

    if (macosPlugin != null) {
      final granted = await macosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    // Android permissions are handled differently
    return true; // Assume granted for Android
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // TODO: Navigate to food detail page using the payload (food ID)
  }

  /// Schedule notification for a food item
  Future<void> scheduleNotificationForFood(FoodItem food) async {
    if (!_initialized) {
      print('⚠️ Notification service not initialized');
      return;
    }

    try {
      // Get settings directly from Firestore
      final settingsDoc = await _firestore
          .collection('settings')
          .doc('user_settings')
          .get();

      if (!settingsDoc.exists) {
        print('⚠️ Settings not found');
        return;
      }

      final settings = AppSettings.fromFirestore(settingsDoc);

      // Check if notifications are enabled
      if (!settings.enablePushNotifications) {
        print('🔕 Notifications disabled in settings');
        return;
      }

      // Calculate notification time (days before expiry)
      final notificationDate = food.expiryDate.subtract(
        Duration(days: settings.expiryAlertDays),
      );

      // Don't schedule if notification time is in the past
      if (notificationDate.isBefore(DateTime.now())) {
        print('⏰ Notification time is in the past for ${food.name}');
        return;
      }

      // Convert to timezone-aware datetime
      final scheduledDate = tz.TZDateTime.from(
        notificationDate,
        tz.local,
      );

      // Create notification
      await _notifications.zonedSchedule(
        food.id.hashCode, // Use food ID hash as notification ID
        '🍎 Food Expiry Alert',
        '${food.name} will expire in ${settings.expiryAlertDays} days!',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'food_expiry_channel',
            'Food Expiry Alerts',
            channelDescription:
                'Notifications for food items that are about to expire',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: food.id, // Pass food ID to navigate when tapped
      );

      print('✅ Scheduled notification for ${food.name} at $scheduledDate');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  /// Cancel notification for a food item
  Future<void> cancelNotificationForFood(String foodId) async {
    if (!_initialized) return;

    try {
      await _notifications.cancel(foodId.hashCode);
      print('🔕 Cancelled notification for food ID: $foodId');
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  /// Reschedule all food notifications (called when settings change)
  Future<void> rescheduleAllNotifications() async {
    if (!_initialized) {
      print('⚠️ Notification service not initialized');
      return;
    }

    try {
      print('🔄 Rescheduling all notifications...');

      // Cancel all existing notifications
      await _notifications.cancelAll();

      // Get all foods directly from Firestore
      final foodsSnapshot = await _firestore
          .collection('foods')
          .where('isDeleted', isEqualTo: false)
          .get();

      final foods = foodsSnapshot.docs
          .map((doc) => FoodItem.fromFirestore(doc))
          .toList();

      // Schedule notification for each food
      for (final food in foods) {
        await scheduleNotificationForFood(food);
      }

      print('✅ Rescheduled ${foods.length} notifications');
    } catch (e) {
      print('❌ Error rescheduling notifications: $e');
    }
  }

  /// Get all pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('🔕 Cancelled all notifications');
  }

  /// Schedule daily summary notification
  Future<void> scheduleDailySummary(String time) async {
    if (!_initialized) return;

    try {
      // Get settings directly from Firestore
      final settingsDoc = await _firestore
          .collection('settings')
          .doc('user_settings')
          .get();

      if (!settingsDoc.exists) {
        print('⚠️ Settings not found');
        return;
      }

      final settings = AppSettings.fromFirestore(settingsDoc);

      if (!settings.dailySummaryEnabled) {
        await _notifications.cancel(999999); // Use fixed ID for daily summary
        return;
      }

      // Parse time (format: "HH:mm")
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Create time for today
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notifications.zonedSchedule(
        999999, // Fixed ID for daily summary
        '📊 Daily Food Summary',
        'Check your food inventory for expiring items',
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_summary_channel',
            'Daily Summary',
            channelDescription: 'Daily summary of your food inventory',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );

      print('✅ Scheduled daily summary at $hour:$minute');
    } catch (e) {
      print('❌ Error scheduling daily summary: $e');
    }
  }

  /// Show an immediate test notification (for testing purposes)
  Future<bool> showImmediateTestNotification({
    String? title,
    String? body,
  }) async {
    if (!_initialized) {
      print('⚠️ Notification service not initialized');
      return false;
    }

    try {
      // Check permissions first
      print('🔍 Checking notification permissions...');
      final hasPermission = await areNotificationsEnabled();

      if (!hasPermission) {
        print('❌ Notification permissions not granted!');
        print('💡 Please enable notifications in Settings > Notifications > Food Tracking');
        return false;
      }

      print('✅ Permissions OK, showing notification...');

      await _notifications.show(
        999998, // Fixed ID for test notification
        title ?? '🧪 Test Notification',
        body ?? 'This is a test notification displayed immediately!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Notifications',
            channelDescription: 'Channel for testing notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'test_notification',
      );
      print('✅ Immediate test notification sent successfully!');
      return true;
    } catch (e) {
      print('❌ Error showing test notification: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
    }
  }
}

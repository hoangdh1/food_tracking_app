import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/settings_model.dart';
import '../services/notification_service.dart';

class SettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'settings';
  static const String _defaultDocId = 'user_settings';
  final NotificationService _notificationService = NotificationService();

  DocumentReference get _settingsDoc =>
      _firestore.collection(_collection).doc(_defaultDocId);

  // READ - Get settings (create default if not exists)
  Future<AppSettings> getSettings() async {
    try {
      final doc = await _settingsDoc.get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['isDeleted'] == false) {
          return AppSettings.fromFirestore(doc);
        }
      }
      
      // Create default settings if not exists
      return await _createDefaultSettings();
    } catch (e) {
      throw Exception('Failed to get settings: $e');
    }
  }

  // READ - Stream settings (real-time updates)
  Stream<AppSettings> streamSettings() {
    return _settingsDoc.snapshots().asyncMap((doc) async {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['isDeleted'] == false) {
          return AppSettings.fromFirestore(doc);
        }
      }
      // Return default settings if not exists
      return await _createDefaultSettings();
    });
  }

  // CREATE - Create default settings
  Future<AppSettings> _createDefaultSettings() async {
    try {
      final now = DateTime.now();
      final defaultSettings = AppSettings(
        id: _defaultDocId,
        enablePushNotifications: true,
        expiryAlertDays: 3,
        dailySummaryEnabled: false,
        summaryTime: '09:00',
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      );
      
      await _settingsDoc.set(defaultSettings.toMap());
      print('✅ Created default settings');
      return defaultSettings;
    } catch (e) {
      throw Exception('Failed to create default settings: $e');
    }
  }

  // UPDATE - Update entire settings
  Future<void> updateSettings(AppSettings settings) async {
    try {
      await _settingsDoc.update(
        settings.copyWith(updatedAt: DateTime.now()).toMap(),
      );
    } catch (e) {
      // If document doesn't exist, create it
      if (e.toString().contains('NOT_FOUND')) {
        await _settingsDoc.set(
          settings.copyWith(updatedAt: DateTime.now()).toMap(),
        );
      } else {
        throw Exception('Failed to update settings: $e');
      }
    }
  }

  // UPDATE - Update specific fields
  Future<void> updateSettingsFields(Map<String, dynamic> fields) async {
    try {
      fields['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _settingsDoc.update(fields);
    } catch (e) {
      // If document doesn't exist, create default first
      if (e.toString().contains('NOT_FOUND')) {
        await _createDefaultSettings();
        fields['updatedAt'] = Timestamp.fromDate(DateTime.now());
        await _settingsDoc.update(fields);
      } else {
        throw Exception('Failed to update settings fields: $e');
      }
    }
  }

  // UPDATE - Toggle push notifications
  Future<void> togglePushNotifications(bool enabled) async {
    try {
      await updateSettingsFields({
        'enablePushNotifications': enabled,
      });

      // Reschedule all notifications when toggled
      if (enabled) {
        await _notificationService.rescheduleAllNotifications();
      } else {
        await _notificationService.cancelAllNotifications();
      }
    } catch (e) {
      throw Exception('Failed to toggle push notifications: $e');
    }
  }

  // UPDATE - Update expiry alert days
  Future<void> updateExpiryAlertDays(int days) async {
    try {
      if (days < 1 || days > 30) {
        throw Exception('Expiry alert days must be between 1 and 30');
      }
      await updateSettingsFields({
        'expiryAlertDays': days,
      });

      // Reschedule all notifications with new alert days
      await _notificationService.rescheduleAllNotifications();
    } catch (e) {
      throw Exception('Failed to update expiry alert days: $e');
    }
  }

  // UPDATE - Toggle daily summary
  Future<void> toggleDailySummary(bool enabled) async {
    try {
      await updateSettingsFields({
        'dailySummaryEnabled': enabled,
      });

      // Update daily summary notification
      final settings = await getSettings();
      await _notificationService.scheduleDailySummary(settings.summaryTime);
    } catch (e) {
      throw Exception('Failed to toggle daily summary: $e');
    }
  }

  // UPDATE - Update summary time
  Future<void> updateSummaryTime(String time) async {
    try {
      // Validate time format (HH:mm)
      final timeParts = time.split(':');
      if (timeParts.length != 2) {
        throw Exception('Invalid time format. Use HH:mm');
      }

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);

      if (hour == null || hour < 0 || hour > 23) {
        throw Exception('Invalid hour. Must be between 0 and 23');
      }
      if (minute == null || minute < 0 || minute > 59) {
        throw Exception('Invalid minute. Must be between 0 and 59');
      }

      await updateSettingsFields({
        'summaryTime': time,
      });

      // Reschedule daily summary with new time
      await _notificationService.scheduleDailySummary(time);
    } catch (e) {
      throw Exception('Failed to update summary time: $e');
    }
  }

  // DELETE - Reset to default settings
  Future<void> resetToDefault() async {
    try {
      await _createDefaultSettings();
    } catch (e) {
      throw Exception('Failed to reset settings: $e');
    }
  }

  // UTILITY - Check if settings exist
  Future<bool> settingsExist() async {
    try {
      final doc = await _settingsDoc.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['isDeleted'] == false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // UTILITY - Get push notification status
  Future<bool> isPushNotificationEnabled() async {
    try {
      final settings = await getSettings();
      return settings.enablePushNotifications;
    } catch (e) {
      return true; // Default to enabled
    }
  }

  // UTILITY - Get expiry alert days
  Future<int> getExpiryAlertDays() async {
    try {
      final settings = await getSettings();
      return settings.expiryAlertDays;
    } catch (e) {
      return 3; // Default to 3 days
    }
  }

  // UTILITY - Get daily summary status
  Future<bool> isDailySummaryEnabled() async {
    try {
      final settings = await getSettings();
      return settings.dailySummaryEnabled;
    } catch (e) {
      return false; // Default to disabled
    }
  }

  // UTILITY - Get summary time
  Future<String> getSummaryTime() async {
    try {
      final settings = await getSettings();
      return settings.summaryTime;
    } catch (e) {
      return '09:00'; // Default to 9 AM
    }
  }
}
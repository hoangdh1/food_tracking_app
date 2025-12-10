import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/models/food_model.dart';
import 'data/services/notification_service.dart';

/// Temporary test file to manually test notification functions
/// Run this from your main.dart or a test page
class NotificationTester {
  static final NotificationService _notificationService = NotificationService();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Test 0: Show immediate notification (displays right now!)
  static Future<void> testImmediateNotification() async {
    print('\n🧪 TEST 0: Show Immediate Notification');
    print('━' * 50);

    await _notificationService.showImmediateTestNotification(
      title: '🎉 Test Notification',
      body: 'If you see this, notifications are working!',
    );
    print('✅ Test complete - You should see a notification now!\n');
  }

  /// Test 1: Create a test food item and schedule notification
  static Future<void> testScheduleNotification() async {
    print('\n🧪 TEST 1: Schedule Notification');
    print('━' * 50);

    // Create a test food item that expires in 2 days
    final testFood = FoodItem(
      id: 'test_food_123',
      name: 'Test Apple',
      categoryId: 'test_category',
      expiryDate: DateTime.now().add(const Duration(days: 2)),
      quantity: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
    );

    await _notificationService.scheduleNotificationForFood(testFood);
    print('✅ Test complete - Check console for notification scheduling logs\n');
  }

  /// Test 2: Cancel a notification
  static Future<void> testCancelNotification() async {
    print('\n🧪 TEST 2: Cancel Notification');
    print('━' * 50);

    await _notificationService.cancelNotificationForFood('test_food_123');
    print('✅ Test complete - Check console for cancellation logs\n');
  }

  /// Test 3: Reschedule all existing notifications
  static Future<void> testRescheduleAll() async {
    print('\n🧪 TEST 3: Reschedule All Notifications');
    print('━' * 50);

    await _notificationService.rescheduleAllNotifications();
    print('✅ Test complete - Check console for rescheduling logs\n');
  }

  /// Test 4: Check pending notifications (platform-specific)
  static Future<void> testCheckPendingNotifications() async {
    print('\n🧪 TEST 4: Check Pending Notifications');
    print('━' * 50);

    // This will print how many notifications are currently scheduled
    // The NotificationService logs this during rescheduleAllNotifications
    await _notificationService.rescheduleAllNotifications();
    print('✅ Check console output above for notification count\n');
  }

  /// Test 5: Get all foods and verify they have notifications
  static Future<void> testVerifyAllFoodNotifications() async {
    print('\n🧪 TEST 5: Verify All Food Notifications');
    print('━' * 50);

    try {
      final foodsSnapshot = await _firestore
          .collection('foods')
          .where('isDeleted', isEqualTo: false)
          .get();

      final foods = foodsSnapshot.docs
          .map((doc) => FoodItem.fromFirestore(doc))
          .toList();

      print('📊 Found ${foods.length} active food items:');
      for (var food in foods) {
        final daysUntilExpiry = food.expiryDate.difference(DateTime.now()).inDays;
        print('  • ${food.name} - Expires in $daysUntilExpiry days');
      }

      print('\n🔄 Rescheduling notifications for all foods...');
      await _notificationService.rescheduleAllNotifications();
      print('✅ Test complete\n');
    } catch (e) {
      print('❌ Error: $e\n');
    }
  }

  /// Test 6: Display immediate notifications for ALL foods meeting threshold
  static Future<List<FoodItem>> testShowFoodsNeedingNotification() async {
    print('\n🧪 TEST 6: Send Immediate Notifications for All Foods Meeting Threshold');
    print('━' * 50);

    try {
      // Get settings to know the threshold
      final settingsDoc = await _firestore
          .collection('settings')
          .doc('user_settings')
          .get();

      if (!settingsDoc.exists) {
        print('⚠️ Settings not found, using default threshold of 5 days');
        return [];
      }

      final data = settingsDoc.data()!;
      final expiryAlertDays = data['expiryAlertDays'] as int;

      print('📋 Notification threshold: $expiryAlertDays days before expiry');
      print('');

      // Get all active foods
      final foodsSnapshot = await _firestore
          .collection('foods')
          .where('isDeleted', isEqualTo: false)
          .get();

      final allFoods = foodsSnapshot.docs
          .map((doc) => FoodItem.fromFirestore(doc))
          .toList();

      // Filter foods that meet the threshold
      final now = DateTime.now();
      final foodsNeedingNotification = allFoods.where((food) {
        final daysUntilExpiry = food.expiryDate.difference(now).inDays;
        return daysUntilExpiry >= 0 && daysUntilExpiry <= expiryAlertDays;
      }).toList();

      // Sort by expiry date (soonest first)
      foodsNeedingNotification.sort((a, b) =>
        a.expiryDate.compareTo(b.expiryDate));

      print('🔔 Foods meeting notification threshold:');
      print('━' * 50);

      if (foodsNeedingNotification.isEmpty) {
        print('✅ No foods currently need notifications!');
        print('   All items are either expired or have more than $expiryAlertDays days left.');
        print('\n✅ Test complete - No notifications sent\n');
        return [];
      }

      print('Found ${foodsNeedingNotification.length} items that will receive notifications\n');

      // Send immediate notification for EACH food item
      int successCount = 0;
      for (var i = 0; i < foodsNeedingNotification.length; i++) {
        final food = foodsNeedingNotification[i];
        final daysLeft = food.expiryDate.difference(now).inDays;

        String emoji;
        if (daysLeft == 0) {
          emoji = '🔴';
        } else if (daysLeft == 1) {
          emoji = '🟠';
        } else if (daysLeft <= 3) {
          emoji = '🟡';
        } else {
          emoji = '🟢';
        }

        // Create notification message
        String body;
        if (daysLeft == 0) {
          body = '${food.name} expires TODAY! Use it soon.';
        } else if (daysLeft == 1) {
          body = '${food.name} expires TOMORROW!';
        } else {
          body = '${food.name} expires in $daysLeft days';
        }

        print('$emoji Sending notification #${i + 1}: ${food.name} ($daysLeft days left)');

        // Send immediate notification
        final success = await _notificationService.showImmediateTestNotification(
          title: '⚠️ Food Expiry Alert',
          body: body,
        );

        if (success) {
          successCount++;
        }

        // Small delay between notifications so they don't overlap on screen
        if (i < foodsNeedingNotification.length - 1) {
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }

      print('');
      print('━' * 50);
      print('✅ Sent $successCount/${foodsNeedingNotification.length} notifications successfully!');
      print('📱 Check your iPhone - you should see notification banners!');
      print('\n✅ Test complete\n');

      return foodsNeedingNotification;
    } catch (e) {
      print('❌ Error: $e\n');
      return [];
    }
  }

  /// Run all tests in sequence
  static Future<void> runAllTests() async {
    print('\n╔════════════════════════════════════════════╗');
    print('║   NOTIFICATION SERVICE TEST SUITE          ║');
    print('╚════════════════════════════════════════════╝\n');

    await testImmediateNotification();
    await Future.delayed(const Duration(seconds: 1));

    await testScheduleNotification();
    await Future.delayed(const Duration(seconds: 1));

    await testCheckPendingNotifications();
    await Future.delayed(const Duration(seconds: 1));

    await testCancelNotification();
    await Future.delayed(const Duration(seconds: 1));

    await testVerifyAllFoodNotifications();
    await Future.delayed(const Duration(seconds: 1));

    await testShowFoodsNeedingNotification();

    print('╔════════════════════════════════════════════╗');
    print('║   ALL TESTS COMPLETED                      ║');
    print('╚════════════════════════════════════════════╝\n');
  }
}

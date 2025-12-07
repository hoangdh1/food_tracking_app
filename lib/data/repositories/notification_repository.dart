import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notifications';

  CollectionReference get _notificationCollection => _firestore.collection(_collection);

  // CREATE - Add a new notification
  Future<String> addNotification(NotificationItem notification) async {
    try {
      final docRef = await _notificationCollection.add(notification.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add notification: $e');
    }
  }

  // CREATE - Batch add multiple notifications
  Future<void> addNotifications(List<NotificationItem> notifications) async {
    try {
      final batch = _firestore.batch();
      
      for (var notification in notifications) {
        final docRef = _notificationCollection.doc();
        batch.set(docRef, notification.toMap());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add notifications: $e');
    }
  }

  // READ - Get all non-deleted notifications
  Future<List<NotificationItem>> getAllNotifications() async {
    try {
      final snapshot = await _notificationCollection
          .where('isDeleted', isEqualTo: false)
          .orderBy('sentAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => NotificationItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  // READ - Get notification by ID
  Future<NotificationItem?> getNotificationById(String id) async {
    try {
      final doc = await _notificationCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['isDeleted'] == false) {
          return NotificationItem.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get notification: $e');
    }
  }

  // READ - Get notifications by food ID
  Future<List<NotificationItem>> getNotificationsByFoodId(String foodId) async {
    try {
      final snapshot = await _notificationCollection
          .where('foodId', isEqualTo: foodId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('sentAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => NotificationItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get notifications for food: $e');
    }
  }

  // READ - Get pending notifications
  Future<List<NotificationItem>> getPendingNotifications() async {
    try {
      final snapshot = await _notificationCollection
          .where('status', isEqualTo: 'pending')
          .where('isDeleted', isEqualTo: false)
          .orderBy('sentAt', descending: false)
          .get();
      
      return snapshot.docs
          .map((doc) => NotificationItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending notifications: $e');
    }
  }

  // READ - Get notifications by status
  Future<List<NotificationItem>> getNotificationsByStatus(String status) async {
    try {
      final snapshot = await _notificationCollection
          .where('status', isEqualTo: status)
          .where('isDeleted', isEqualTo: false)
          .orderBy('sentAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => NotificationItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get notifications by status: $e');
    }
  }

  // READ - Get notifications by type
  Future<List<NotificationItem>> getNotificationsByType(String type) async {
    try {
      final snapshot = await _notificationCollection
          .where('type', isEqualTo: type)
          .where('isDeleted', isEqualTo: false)
          .orderBy('sentAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => NotificationItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get notifications by type: $e');
    }
  }

  // READ - Stream notifications (real-time updates)
  Stream<List<NotificationItem>> streamAllNotifications() {
    return _notificationCollection
        .where('isDeleted', isEqualTo: false)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationItem.fromFirestore(doc))
            .toList());
  }

  // UPDATE - Update notification
  Future<void> updateNotification(String id, NotificationItem notification) async {
    try {
      await _notificationCollection.doc(id).update(
        notification.copyWith(updatedAt: DateTime.now()).toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update notification: $e');
    }
  }

  // UPDATE - Update specific fields
  Future<void> updateNotificationFields(String id, Map<String, dynamic> fields) async {
    try {
      fields['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _notificationCollection.doc(id).update(fields);
    } catch (e) {
      throw Exception('Failed to update notification fields: $e');
    }
  }

  // UPDATE - Mark notification as sent
  Future<void> markAsSent(String id) async {
    try {
      await _notificationCollection.doc(id).update({
        'status': 'sent',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as sent: $e');
    }
  }

  // UPDATE - Mark notification as read
  Future<void> markAsRead(String id) async {
    try {
      await _notificationCollection.doc(id).update({
        'status': 'read',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // UPDATE - Mark notification as failed
  Future<void> markAsFailed(String id) async {
    try {
      await _notificationCollection.doc(id).update({
        'status': 'failed',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as failed: $e');
    }
  }

  // UPDATE - Batch update status
  Future<void> batchUpdateStatus(List<String> ids, String status) async {
    try {
      final batch = _firestore.batch();
      final now = Timestamp.fromDate(DateTime.now());
      
      for (var id in ids) {
        batch.update(
          _notificationCollection.doc(id),
          {
            'status': status,
            'updatedAt': now,
          },
        );
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update status: $e');
    }
  }

  // DELETE - Soft delete a notification
  Future<void> deleteNotification(String id) async {
    try {
      await _notificationCollection.doc(id).update({
        'isDeleted': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // DELETE - Permanently delete (use with caution)
  Future<void> permanentlyDeleteNotification(String id) async {
    try {
      await _notificationCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to permanently delete notification: $e');
    }
  }

  // DELETE - Delete all notifications for a food item
  Future<void> deleteNotificationsByFoodId(String foodId) async {
    try {
      final notifications = await getNotificationsByFoodId(foodId);
      final batch = _firestore.batch();
      final now = Timestamp.fromDate(DateTime.now());
      
      for (var notification in notifications) {
        batch.update(
          _notificationCollection.doc(notification.id),
          {
            'isDeleted': true,
            'updatedAt': now,
          },
        );
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete notifications for food: $e');
    }
  }

  // DELETE - Delete old notifications (older than X days)
  Future<int> deleteOldNotifications({int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final snapshot = await _notificationCollection
          .where('sentAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .where('isDeleted', isEqualTo: false)
          .get();
      
      final batch = _firestore.batch();
      final now = Timestamp.fromDate(DateTime.now());
      
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isDeleted': true,
          'updatedAt': now,
        });
      }
      
      await batch.commit();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to delete old notifications: $e');
    }
  }

  // STATS - Get notification statistics
  Future<Map<String, int>> getStatistics() async {
    try {
      final allNotifications = await getAllNotifications();
      
      final stats = <String, int>{
        'total': allNotifications.length,
        'pending': 0,
        'sent': 0,
        'read': 0,
        'failed': 0,
      };
      
      for (var notification in allNotifications) {
        stats[notification.status] = (stats[notification.status] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      throw Exception('Failed to get notification statistics: $e');
    }
  }
}
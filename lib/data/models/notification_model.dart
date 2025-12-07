import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String foodId;
  final String type; // 'expiry_warning', 'expired', 'daily_summary'
  final DateTime sentAt;
  final String status; // 'pending', 'sent', 'failed', 'read'
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationItem({
    required this.id,
    required this.foodId,
    required this.type,
    required this.sentAt,
    this.status = 'pending',
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert NotificationItem to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'type': type,
      'sentAt': Timestamp.fromDate(sentAt),
      'status': status,
      'isDeleted': isDeleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create NotificationItem from Firestore document
  factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationItem(
      id: doc.id,
      foodId: data['foodId'] ?? '',
      type: data['type'] ?? '',
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      isDeleted: data['isDeleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Create NotificationItem from Map
  factory NotificationItem.fromMap(String id, Map<String, dynamic> data) {
    return NotificationItem(
      id: id,
      foodId: data['foodId'] ?? '',
      type: data['type'] ?? '',
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      isDeleted: data['isDeleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Create a copy with updated fields
  NotificationItem copyWith({
    String? id,
    String? foodId,
    String? type,
    DateTime? sentAt,
    String? status,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      type: type ?? this.type,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NotificationItem(id: $id, type: $type, status: $status)';
  }
}
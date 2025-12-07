import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettings {
  final String id;
  final bool enablePushNotifications;
  final int expiryAlertDays;
  final bool dailySummaryEnabled;
  final String summaryTime; // Format: "HH:mm" e.g., "09:00"
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppSettings({
    required this.id,
    this.enablePushNotifications = true,
    this.expiryAlertDays = 3,
    this.dailySummaryEnabled = false,
    this.summaryTime = '09:00',
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert AppSettings to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'enablePushNotifications': enablePushNotifications,
      'expiryAlertDays': expiryAlertDays,
      'dailySummaryEnabled': dailySummaryEnabled,
      'summaryTime': summaryTime,
      'isDeleted': isDeleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create AppSettings from Firestore document
  factory AppSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppSettings(
      id: doc.id,
      enablePushNotifications: data['enablePushNotifications'] ?? true,
      expiryAlertDays: data['expiryAlertDays'] ?? 3,
      dailySummaryEnabled: data['dailySummaryEnabled'] ?? false,
      summaryTime: data['summaryTime'] ?? '09:00',
      isDeleted: data['isDeleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Create AppSettings from Map
  factory AppSettings.fromMap(String id, Map<String, dynamic> data) {
    return AppSettings(
      id: id,
      enablePushNotifications: data['enablePushNotifications'] ?? true,
      expiryAlertDays: data['expiryAlertDays'] ?? 3,
      dailySummaryEnabled: data['dailySummaryEnabled'] ?? false,
      summaryTime: data['summaryTime'] ?? '09:00',
      isDeleted: data['isDeleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Create a copy with updated fields
  AppSettings copyWith({
    String? id,
    bool? enablePushNotifications,
    int? expiryAlertDays,
    bool? dailySummaryEnabled,
    String? summaryTime,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      id: id ?? this.id,
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      expiryAlertDays: expiryAlertDays ?? this.expiryAlertDays,
      dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
      summaryTime: summaryTime ?? this.summaryTime,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AppSettings(id: $id, pushEnabled: $enablePushNotifications, alertDays: $expiryAlertDays)';
  }
}
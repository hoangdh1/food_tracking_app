import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String id;
  final String name;
  final int quantity;
  final DateTime expiryDate;
  final DateTime? predictedExpiry;
  final String categoryId;
  final String source;
  final String imageUrl;
  final int notificationThreshold;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  FoodItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.expiryDate,
    this.predictedExpiry,
    required this.categoryId,
    this.source = '',
    this.imageUrl = '',
    this.notificationThreshold = 3,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate days until expiry
  int get daysUntilExpiry {
    final now = DateTime.now();
    final expiryToUse = predictedExpiry ?? expiryDate;
    final difference = expiryToUse.difference(now);
    return difference.inDays;
  }

  // Get status based on expiry
  String get status {
    final days = daysUntilExpiry;
    if (days < 0) return 'expired';
    if (days <= notificationThreshold) return 'expiring_soon';
    return 'fresh';
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case 'expired':
        return 'red';
      case 'expiring_soon':
        return 'orange';
      default:
        return 'green';
    }
  }

  // Convert FoodItem to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'predictedExpiry': predictedExpiry != null 
          ? Timestamp.fromDate(predictedExpiry!) 
          : null,
      'categoryId': categoryId,
      'source': source,
      'imageUrl': imageUrl,
      'notificationThreshold': notificationThreshold,
      'isDeleted': isDeleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create FoodItem from Firestore document
  factory FoodItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodItem(
      id: doc.id,
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      predictedExpiry: data['predictedExpiry'] != null
          ? (data['predictedExpiry'] as Timestamp).toDate()
          : null,
      categoryId: data['categoryId'] ?? '',
      source: data['source'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      notificationThreshold: data['notificationThreshold'] ?? 3,
      isDeleted: data['isDeleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Create FoodItem from Map
  factory FoodItem.fromMap(String id, Map<String, dynamic> data) {
    return FoodItem(
      id: id,
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      predictedExpiry: data['predictedExpiry'] != null
          ? (data['predictedExpiry'] as Timestamp).toDate()
          : null,
      categoryId: data['categoryId'] ?? '',
      source: data['source'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      notificationThreshold: data['notificationThreshold'] ?? 3,
      isDeleted: data['isDeleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Create a copy with updated fields
  FoodItem copyWith({
    String? id,
    String? name,
    int? quantity,
    DateTime? expiryDate,
    DateTime? predictedExpiry,
    String? categoryId,
    String? source,
    String? imageUrl,
    int? notificationThreshold,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
      predictedExpiry: predictedExpiry ?? this.predictedExpiry,
      categoryId: categoryId ?? this.categoryId,
      source: source ?? this.source,
      imageUrl: imageUrl ?? this.imageUrl,
      notificationThreshold: notificationThreshold ?? this.notificationThreshold,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'FoodItem(id: $id, name: $name, quantity: $quantity, expiryDate: $expiryDate)';
  }
}
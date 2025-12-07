import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_model.dart';

class FoodRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'foods';

  CollectionReference get _foodCollection => _firestore.collection(_collection);

  // CREATE - Add a new food item
Future<String> addFood(FoodItem food) async {
  try {
    print('📝 REPO: addFood called');
    print('📝 REPO: Food name: ${food.name}');
    
    final foodMap = food.toMap();
    print('📝 REPO: Food map created');
    
    print('📝 REPO: Adding to Firestore collection "foods"... ${foodMap}');
    final docRef = await _foodCollection.add(foodMap);
    
    print('✅ REPO: Document added successfully!');
    print('✅ REPO: Document ID: ${docRef.id}');
    print('✅ REPO: Document path: ${docRef.path}');
    
    // Verify the write
    print('🔍 REPO: Verifying document exists...');
    final doc = await docRef.get();
    
    if (doc.exists) {
      print('✅ REPO: Document verified on server!');
      print('✅ REPO: Data: ${doc.data()}');
    } else {
      print('⚠️ REPO: Document not found on server (may be cached)');
    }
    
    return docRef.id;
  } catch (e, stackTrace) {
    print('❌ REPO ERROR: $e');
    print('❌ REPO STACK: $stackTrace');
    throw Exception('Failed to add food: $e');
  }
}



  // READ - Get all non-deleted foods
  Future<List<FoodItem>> getAllFoods() async {
    try {
      final snapshot = await _foodCollection
          .where('isDeleted', isEqualTo: false)
          .orderBy('expiryDate', descending: false)
          .get();
      
      return snapshot.docs
          .map((doc) => FoodItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get foods: $e');
    }
  }

  // READ - Get food by ID
  Future<FoodItem?> getFoodById(String id) async {
    try {
      final doc = await _foodCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['isDeleted'] == false) {
          return FoodItem.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get food: $e');
    }
  }

  // READ - Stream all foods (real-time updates)
  Stream<List<FoodItem>> streamAllFoods() {
    return _foodCollection
        .where('isDeleted', isEqualTo: false)
        .orderBy('expiryDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodItem.fromFirestore(doc))
            .toList());
  }

  // READ - Get foods by category
  Future<List<FoodItem>> getFoodsByCategory(String categoryId) async {
    try {
      final snapshot = await _foodCollection
          .where('categoryId', isEqualTo: categoryId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('expiryDate', descending: false)
          .get();
      
      return snapshot.docs
          .map((doc) => FoodItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get foods by category: $e');
    }
  }

  // READ - Get expiring soon foods
  Future<List<FoodItem>> getExpiringSoonFoods({int daysThreshold = 5}) async {
    try {
      final now = DateTime.now();
      final thresholdDate = now.add(Duration(days: daysThreshold));
      
      final snapshot = await _foodCollection
          .where('isDeleted', isEqualTo: false)
          .where('expiryDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('expiryDate', isLessThanOrEqualTo: Timestamp.fromDate(thresholdDate))
          .orderBy('expiryDate', descending: false)
          .get();
      
      return snapshot.docs
          .map((doc) => FoodItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expiring foods: $e');
    }
  }

  // READ - Get expired foods
  Future<List<FoodItem>> getExpiredFoods() async {
    try {
      final now = DateTime.now();
      
      final snapshot = await _foodCollection
          .where('isDeleted', isEqualTo: false)
          .where('expiryDate', isLessThan: Timestamp.fromDate(now))
          .orderBy('expiryDate', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => FoodItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get expired foods: $e');
    }
  }

  // READ - Search foods by name
  Future<List<FoodItem>> searchFoodsByName(String searchTerm) async {
    try {
      // Get all foods and filter locally (Firestore doesn't support contains)
      final allFoods = await getAllFoods();
      final searchLower = searchTerm.toLowerCase();
      
      return allFoods
          .where((food) => food.name.toLowerCase().contains(searchLower))
          .toList();
    } catch (e) {
      throw Exception('Failed to search foods: $e');
    }
  }

  // UPDATE - Update an existing food item
  Future<void> updateFood(String id, FoodItem food) async {
    try {
      await _foodCollection.doc(id).update(
        food.copyWith(updatedAt: DateTime.now()).toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update food: $e');
    }
  }

  // UPDATE - Update specific fields
  Future<void> updateFoodFields(String id, Map<String, dynamic> fields) async {
    try {
      fields['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _foodCollection.doc(id).update(fields);
    } catch (e) {
      throw Exception('Failed to update food fields: $e');
    }
  }

  // DELETE - Soft delete a food item
  Future<void> deleteFood(String id) async {
    try {
      await _foodCollection.doc(id).update({
        'isDeleted': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to delete food: $e');
    }
  }

  // DELETE - Permanently delete (use with caution)
  Future<void> permanentlyDeleteFood(String id) async {
    try {
      await _foodCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to permanently delete food: $e');
    }
  }

  // DELETE - Batch soft delete expired foods
  Future<int> deleteAllExpiredFoods() async {
    try {
      final expiredFoods = await getExpiredFoods();
      final batch = _firestore.batch();
      
      for (var food in expiredFoods) {
        batch.update(
          _foodCollection.doc(food.id),
          {
            'isDeleted': true,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          },
        );
      }
      
      await batch.commit();
      return expiredFoods.length;
    } catch (e) {
      throw Exception('Failed to delete expired foods: $e');
    }
  }

  // STATS - Get food statistics
  Future<Map<String, int>> getStatistics() async {
    try {
      final allFoods = await getAllFoods();
      
      int total = allFoods.length;
      int expiringSoon = 0;
      int expired = 0;
      
      for (var food in allFoods) {
        final days = food.daysUntilExpiry;
        if (days < 0) {
          expired++;
        } else if (days <= food.notificationThreshold) {
          expiringSoon++;
        }
      }
      
      return {
        'total': total,
        'expiringSoon': expiringSoon,
        'expired': expired,
        'fresh': total - expiringSoon - expired,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  // UTILITY - Get count by category
  Future<Map<String, int>> getCountByCategory() async {
    try {
      final allFoods = await getAllFoods();
      final countMap = <String, int>{};
      
      for (var food in allFoods) {
        countMap[food.categoryId] = (countMap[food.categoryId] ?? 0) + 1;
      }
      
      return countMap;
    } catch (e) {
      throw Exception('Failed to get count by category: $e');
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categories';

  CollectionReference get _categoryCollection => _firestore.collection(_collection);

  // CREATE - Add a new category
  Future<String> addCategory(Category category) async {
    try {
      final docRef = await _categoryCollection.add(category.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  // READ - Get all non-deleted categories
  Future<List<Category>> getAllCategories() async {
    try {
      final snapshot = await _categoryCollection
          .where('isDeleted', isEqualTo: false)
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  // READ - Get category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      final doc = await _categoryCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['isDeleted'] == false) {
          return Category.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }

  // READ - Stream categories (real-time updates)
  Stream<List<Category>> streamAllCategories() {
    return _categoryCollection
        .where('isDeleted', isEqualTo: false)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromFirestore(doc))
            .toList());
  }

  // READ - Get category by name
  Future<Category?> getCategoryByName(String name) async {
    try {
      final snapshot = await _categoryCollection
          .where('name', isEqualTo: name)
          .where('isDeleted', isEqualTo: false)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return Category.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get category by name: $e');
    }
  }

  // UPDATE - Update an existing category
  Future<void> updateCategory(String id, Category category) async {
    try {
      await _categoryCollection.doc(id).update(
        category.copyWith(updatedAt: DateTime.now()).toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // UPDATE - Update specific fields
  Future<void> updateCategoryFields(String id, Map<String, dynamic> fields) async {
    try {
      fields['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _categoryCollection.doc(id).update(fields);
    } catch (e) {
      throw Exception('Failed to update category fields: $e');
    }
  }

  // DELETE - Soft delete a category
  Future<void> deleteCategory(String id) async {
    try {
      await _categoryCollection.doc(id).update({
        'isDeleted': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // DELETE - Permanently delete (use with caution)
  Future<void> permanentlyDeleteCategory(String id) async {
    try {
      await _categoryCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to permanently delete category: $e');
    }
  }

  // UTILITY - Initialize default categories
  Future<void> initializeDefaultCategories() async {
    try {
      // Check if categories already exist
      final existing = await getAllCategories();
      if (existing.isNotEmpty) {
        print('✅ Categories already initialized (${existing.length} categories)');
        return;
      }

      final defaultCategories = [
        'Dairy',
        'Meat',
        'Vegetable',
        'Fruit',
        'Pantry',
        'Bakery',
        'Seafood',
        'Frozen',
        'Beverage',
        'Other',
      ];

      final batch = _firestore.batch();
      final now = DateTime.now();

      for (var name in defaultCategories) {
        final docRef = _categoryCollection.doc();
        final category = Category(
          id: docRef.id,
          name: name,
          createdAt: now,
          updatedAt: now,
        );
        batch.set(docRef, category.toMap());
      }

      await batch.commit();
      print('✅ Initialized ${defaultCategories.length} default categories');
    } catch (e) {
      throw Exception('Failed to initialize categories: $e');
    }
  }

  // UTILITY - Check if category exists by name
  Future<bool> categoryExists(String name) async {
    try {
      final category = await getCategoryByName(name);
      return category != null;
    } catch (e) {
      return false;
    }
  }

  // UTILITY - Get categories map (id -> category)
  Future<Map<String, Category>> getCategoriesMap() async {
    try {
      final categories = await getAllCategories();
      final map = <String, Category>{};
      for (var category in categories) {
        map[category.id] = category;
      }
      return map;
    } catch (e) {
      throw Exception('Failed to get categories map: $e');
    }
  }
}
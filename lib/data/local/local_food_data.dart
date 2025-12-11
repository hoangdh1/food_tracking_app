import '../models/food_model.dart';

/// Local hardcoded food data - this is the master list of all available foods
/// The actual displayed foods will be filtered based on API responses
class LocalFoodData {
  // Mapping from local ID to Firestore ID
  // This allows us to use the Firestore ID when displaying/navigating
  static final Map<String, String> localIdToFirestoreId = {
    'marigold_hl_milk_001': 'DC38OCIASQr5itRPIwwJ',
    'meiji_fresh_milk_001': 'FfTvja3Nlnwbw01PN1z6',
    'pokka_green_tea_001': 'FuYqU0BlW5Voqx57dsz4',
    'coca_cola_can_001': 'JNyRLQ3APgntuPrfxnVt',
    'calbee_chips_001': 'MM7PIgReMmKDoDyxEVmr',
    'oreo_cookies_001': 'MTRwqd2OAovNBfJaM1TK',
    'maggi_curry_noodles_001': 'OCv9xyzR5ECJMDgiEyrw',
    'ayam_sardines_001': 'XWMhRXQjKlaATJSDkz0V',
    'milo_tin_001': 'Y2RR2EAjhNy4YmDwTgZJ',
    'nutella_jar_001': 'edRFWXIlUGozExx8VGPo',
    'bananas_001': 'jeY0jUEJS1h8y8uqstiy',
    'red_apples_001': 'oCp4MqlNIGVukBxfc4AT',
    'labubu_001': 'rR85R6TuaD6hmpcO8flR',
  };

  // Static list of all available foods
  static final List<FoodItem> allFoods = [
    // Marigold HL Milk (1L)
    FoodItem(
      id: 'marigold_hl_milk_001', // DC38OCIASQr5itRPIwwJ
      name: 'Marigold HL Milk (1L)',
      quantity: 1,
      expiryDate: DateTime(2025, 12, 25), // ~2 weeks for UHT milk once opened
      predictedExpiry: DateTime(2025, 12, 23),
      categoryId: 'dairy',
      source: 'supermarket',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAt4jsbJ0YBb7NandmvZsrTQYHNbtnedcNHGBQaz7UVOlrMw7AO-bxdPNuuY7um6KfhwpGgYgBYjNaAgbnF2eBqc3bXC4tUFMlrkuBv301MsFR6G2Ji3B1TUrKHA4q084eHUcYIC54qCLvz8DiRPlDlfjLoGQboWXov90ZUU0nMq71Hi8kdN2s2927b9D4Vs8rV6XswtRpejk4wy9ORGfQyrmt700pgBYQ4ZI21BPUHzSQeYD0jkbwvY5YEXIQ4ZEiVNXSNUBnNKaQ',
      notificationThreshold: 3,
      isDeleted: false,
      createdAt: DateTime(2025, 12, 11),
      updatedAt: DateTime(2025, 12, 11),
    ),

    // Meiji Fresh Milk (1L)
    FoodItem(
      id: 'meiji_fresh_milk_001', // FfTvja3Nlnwbw01PN1z6
      name: 'Meiji Fresh Milk (1L)',
      quantity: 1,
      expiryDate: DateTime(2025, 12, 18), // ~1 week for fresh milk
      predictedExpiry: DateTime(2025, 12, 17),
      categoryId: 'dairy',
      source: 'supermarket',
      imageUrl: 'https://example.com/meiji_fresh_milk.jpg',
      notificationThreshold: 2,
      isDeleted: false,
      createdAt: DateTime(2025, 12, 11),
      updatedAt: DateTime(2025, 12, 11),
    ),

    // Pokka Green Tea Bottle
    FoodItem(
      id: 'pokka_green_tea_001', // FuYqU0BlW5Voqx57dsz4
      name: 'Pokka Green Tea Bottle',
      quantity: 1,
      expiryDate: DateTime(2026, 6, 11), // ~6 months for bottled drinks
      predictedExpiry: DateTime(2026, 6, 9),
      categoryId: 'beverages',
      source: 'supermarket',
      imageUrl: 'https://example.com/pokka_green_tea.jpg',
      notificationThreshold: 7,
      isDeleted: false,
      createdAt: DateTime(2025, 12, 11),
      updatedAt: DateTime(2025, 12, 11),
    ),

    // Coca-Cola Can
    FoodItem(
      id: 'coca_cola_can_001', // JNyRLQ3APgntuPrfxnVt
      name: 'Coca-Cola Can',
      quantity: 1,
      expiryDate: DateTime(2026, 9, 11), // ~9 months for canned drinks
      predictedExpiry: DateTime(2026, 9, 9),
      categoryId: 'beverages',
      source: 'supermarket',
      imageUrl: 'https://example.com/coca_cola_can.jpg',
      notificationThreshold: 14,
      isDeleted: false,
      createdAt: DateTime(2025, 12, 11),
      updatedAt: DateTime(2025, 12, 11),
    ),

    // Calbee Hot & Spicy Potato Chips
    FoodItem(
      id: 'calbee_chips_001', // MM7PIgReMmKDoDyxEVmr
      name: 'Calbee Hot & Spicy Potato Chips',
      quantity: 1,
      expiryDate: DateTime(2026, 3, 11), // ~3 months for chips
      predictedExpiry: DateTime(2026, 3, 9),
      categoryId: 'snacks',
      source: 'supermarket',
      imageUrl: 'https://example.com/calbee_chips.jpg',
      notificationThreshold: 7,
      isDeleted: false,
      createdAt: DateTime(2025, 12, 11),
      updatedAt: DateTime(2025, 12, 11),
    ),

    // Oreo Cookies (Original Pack)
    FoodItem(
      id: 'oreo_cookies_001', // MTRwqd2OAovNBfJaM1TK
      name: 'Oreo Cookies (Original Pack)',
      quantity: 1,
      expiryDate: DateTime(2026, 6, 11), // ~6 months for cookies
      predictedExpiry: DateTime(2026, 6, 9),
      categoryId: 'snacks',
      source: 'supermarket',
      imageUrl: 'https://example.com/oreo_cookies.jpg',
      notificationThreshold: 7,
      isDeleted: false,
      createdAt: DateTime(2025, 12, 11),
      updatedAt: DateTime(2025, 12, 11),
    ),

    // Maggi Curry Instant Noodles Pack
    FoodItem(
      id: 'maggi_curry_noodles_001', // OCv9xyzR5ECJMDgiEyrw
      name: 'Maggi Curry Instant Noodles Pack',
      quantity: 1,
      expiryDate: DateTime(2026, 6, 11), // ~6 months for instant noodles
      predictedExpiry: DateTime(2026, 6, 9),
      categoryId: 'instant_food',
      source: 'supermarket',
      imageUrl: 'https://example.com/maggi_curry_noodles.jpg',
      notificationThreshold: 14,
      isDeleted: false,
      createdAt: DateTime(2025, 12, 11),
      updatedAt: DateTime(2025, 12, 11),
    ),

    // Ayam Brand Sardines in Tomato Sauce
    FoodItem(
      id: 'ayam_sardines_001', // XWMhRXQjKlaATJSDkz0V
      name: 'Ayam Brand Sardines in Tomato Sauce',
      quantity: 1,
      expiryDate: DateTime(2027, 12, 11), // ~2 years for canned goods
      predictedExpiry: DateTime(2027, 12, 9),
      categoryId: 'canned_goods',
      source: 'supermarket',
      imageUrl: 'https://example.com/ayam_sardines.jpg',
      notificationThreshold: 30,
      isDeleted: false,
      createdAt: DateTime(2025, 12, 11),
      updatedAt: DateTime(2025, 12, 11),
    ),

    // Milo Tin (Nestlé Milo Powder)
    FoodItem(
      id: 'milo_tin_001', // Y2RR2EAjhNy4YmDwTgZJ
      name: 'Milo Tin (Nestlé Milo Powder)',
      quantity: 1,
      expiryDate: DateTime(2026, 12, 11), // ~1 year for powder drinks
      predictedExpiry: DateTime(2026, 12, 9),
      categoryId: 'beverages',
      source: 'supermarket',
      imageUrl: 'https://example.com/milo_tin.jpg',
      notificationThreshold: 30,
      isDeleted: false,
      createdAt: DateTime(2025, 12, 11),
      updatedAt: DateTime(2025, 12, 11),
    ),

    // Nutella Hazelnut Spread (Jar)
    FoodItem(
      id: 'nutella_jar_001', // edRFWXIlUGozExx8VGPo
      name: 'Nutella Hazelnut Spread (Jar)',
      quantity: 1,
      expiryDate: DateTime(2026, 12, 11), // ~1 year for spreads
      predictedExpiry: DateTime(2026, 12, 9),
      categoryId: 'spreads',
      source: 'supermarket',
      imageUrl: 'https://example.com/nutella_jar.jpg',
      notificationThreshold: 14,
      isDeleted: false,
      createdAt: DateTime(2025, 12, 11),
      updatedAt: DateTime(2025, 12, 11),
    ),

    // Bananas (Common in SG supermarkets — Dole/Del Monte)
    FoodItem(
      id: 'bananas_001', // jeY0jUEJS1h8y8uqstiy
      name: 'Bananas (Dole/Del Monte)',
      quantity: 6,
      expiryDate: DateTime(2025, 12, 18), // ~7 days for bananas
      predictedExpiry: DateTime(2025, 12, 16),
      categoryId: 'fruits',
      source: 'supermarket',
      imageUrl: 'https://example.com/bananas.jpg',
      notificationThreshold: 2,
      isDeleted: false,
      createdAt: DateTime(2025, 12, 11),
      updatedAt: DateTime(2025, 12, 11),
    ),

    // Red Apples (e.g., Fuji / Royal Gala)
    FoodItem(
      id: 'red_apples_001', // oCp4MqlNIGVukBxfc4AT
      name: 'Red Apples (Fuji/Royal Gala)',
      quantity: 4,
      expiryDate: DateTime(2025, 12, 25), // ~2 weeks for apples
      predictedExpiry: DateTime(2025, 12, 23),
      categoryId: 'fruits',
      source: 'supermarket',
      imageUrl: 'https://example.com/red_apples.jpg',
      notificationThreshold: 3,
      isDeleted: false,
      createdAt: DateTime(2025, 12, 11),
      updatedAt: DateTime(2025, 12, 11),
    ),

    // Labubu
    // FoodItem(
    //   id: 'labubu_001', // rR85R6TuaD6hmpcO8flR
    //   name: 'Labubu',
    //   quantity: 1,
    //   expiryDate: DateTime(2025, 12, 31), // forever for Labubu
    //   predictedExpiry: DateTime(2099, 12, 31),
    //   categoryId: 'snacks',
    //   source: 'supermarket',
    //   imageUrl: 'https://example.com/labubu.jpg',
    //   notificationThreshold: 30,
    //   isDeleted: false,
    //   createdAt: DateTime(2025, 12, 11),
    //   updatedAt: DateTime(2025, 12, 11),
    // ),
  ];

  /// Get foods filtered by API response IDs
  /// Only returns foods whose IDs are in the provided list
  static List<FoodItem> getFilteredFoods(List<String> apiIds) {
    if (apiIds.isEmpty) {
      return [];
    }

    return allFoods.where((food) => apiIds.contains(food.id)).toList();
  }

  /// Get all food IDs
  static List<String> getAllFoodIds() {
    return allFoods.map((food) => food.id).toList();
  }

  /// Find a food by ID
  static FoodItem? getFoodById(String id) {
    try {
      return allFoods.firstWhere((food) => food.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get Firestore ID from local ID
  /// Returns the Firestore ID if mapping exists, otherwise returns the original ID
  static String getFirestoreId(String localId) {
    return localIdToFirestoreId[localId] ?? localId;
  }

  /// Get local ID from Firestore ID (reverse lookup)
  /// Returns the local ID if mapping exists, otherwise returns the original ID
  static String getLocalId(String firestoreId) {
    for (var entry in localIdToFirestoreId.entries) {
      if (entry.value == firestoreId) {
        return entry.key;
      }
    }
    return firestoreId;
  }
}

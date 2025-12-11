import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for fetching food data from external API
class FoodApiService {
  static const String _host = '20.40.61.60';
  static const int _port = 5000;
  static const String _getAllFoodPath = '/food-items';

  /// Get the base URL for API calls
  static String get _baseUrl => 'http://$_host:$_port';

  /// Fetch all food IDs from the API
  /// Returns a list of food IDs (e.g., ['red_apples_001', 'banana_001'])
  /// Returns empty list on error
  ///
  /// Expected API response format:
  /// {
  ///   "food_items": [
  ///     {"id": "marigold_hl_milk_001", "name": "Marigold HL Milk (1L)", "quantity": 1},
  ///     {"id": "meiji_fresh_milk_001", "name": "Meiji Fresh Milk (1L)", "quantity": 1}
  ///   ]
  /// }
  Future<List<String>> getAllFoodIds() async {
    try {
      print('📡 Calling API: $_baseUrl$_getAllFoodPath');

      final uri = Uri.parse('$_baseUrl$_getAllFoodPath');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ API request timed out after 10 seconds');
          throw Exception('Request timeout');
        },
      );

      print('📥 Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Parse the JSON response
        final dynamic jsonData = json.decode(response.body);

        // Handle response as a list (old format)
        if (jsonData is List) {
          final foodIds = jsonData.map((id) => id.toString()).toList();
          print('✅ Received ${foodIds.length} food IDs from API');
          print('📋 Food IDs: $foodIds');
          return foodIds;
        }
        // Handle response wrapped in an object (new format)
        else if (jsonData is Map) {
          // Try the new format first: {"food_items": [...]}
          if (jsonData.containsKey('food_items') && jsonData['food_items'] is List) {
            final foodItems = jsonData['food_items'] as List;
            final foodIds = foodItems.map((item) {
              if (item is Map && item.containsKey('id')) {
                return item['id'].toString();
              }
              return item.toString();
            }).toList();

            print('✅ Received ${foodIds.length} food IDs from API');
            print('📋 Food IDs: $foodIds');
            return foodIds;
          }

          // Fallback: Try other common response field names
          final possibleKeys = ['ids', 'foodIds', 'food_ids', 'foods', 'items', 'data'];

          for (var key in possibleKeys) {
            if (jsonData.containsKey(key) && jsonData[key] is List) {
              final list = jsonData[key] as List;
              final foodIds = list.map((item) {
                if (item is Map && item.containsKey('id')) {
                  return item['id'].toString();
                }
                return item.toString();
              }).toList();

              print('✅ Received ${foodIds.length} food IDs from API (key: $key)');
              print('📋 Food IDs: $foodIds');
              return foodIds;
            }
          }

          print('⚠️ API response is an object but no recognized list field found');
          print('📄 Response body: ${response.body}');
          return [];
        }

        print('⚠️ Unexpected response format: ${jsonData.runtimeType}');
        print('📄 Response body: ${response.body}');
        return [];

      } else {
        print('❌ API request failed with status: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching food IDs from API: $e');
      print('📚 Stack trace: $stackTrace');
      return [];
    }
  }

  /// Test the API connection
  Future<bool> testConnection() async {
    try {
      print('🔍 Testing API connection to $_baseUrl...');

      final uri = Uri.parse('$_baseUrl$_getAllFoodPath');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      print('✅ API is reachable! Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ API connection test failed: $e');
      return false;
    }
  }
}

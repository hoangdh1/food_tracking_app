import 'package:flutter/material.dart';
import '../features/home/ui/home_page.dart';
import '../features/add_food/ui/add_food_page.dart';
import '../features/food_detail/ui/food_detail_page.dart';

class AppRouter {
  static const String home = '/';
  static const String addFood = '/add-food';
  static const String foodDetail = '/food-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      
      case addFood:
        return MaterialPageRoute(builder: (_) => const AddFoodPage());
      
      case foodDetail:
        final foodId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => FoodDetailPage(foodId: foodId),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
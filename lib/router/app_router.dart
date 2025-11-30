import 'package:flutter/material.dart';
import '../features/home/ui/home_page.dart';
import '../features/add_food/ui/add_food_page.dart';

class AppRouter {
  static const String home = '/';
  static const String addFood = '/add-food';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case addFood:
        return MaterialPageRoute(builder: (_) => const AddFoodPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
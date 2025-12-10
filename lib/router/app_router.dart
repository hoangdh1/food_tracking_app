import 'package:flutter/material.dart';
import '../features/home/ui/home_page.dart';
import '../features/add_food/ui/add_food_page.dart';
import '../features/food_detail/ui/food_detail_page.dart';
import '../features/notifications/ui/notification_page.dart';
import '../features/settings/ui/test_notification_page.dart';
import '../features/settings/ui/quick_test_page.dart';

class AppRouter {
  static const String home = '/';
  static const String addFood = '/add-food';
  static const String foodDetail = '/food-detail';
  static const String notifications = '/notifications';
  static const String testNotifications = '/test-notifications';
  static const String quickTest = '/quick-test';

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
      
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationPage());

      case testNotifications:
        return MaterialPageRoute(builder: (_) => const TestNotificationPage());

      case quickTest:
        return MaterialPageRoute(builder: (_) => const QuickTestPage());

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
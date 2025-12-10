import 'package:flutter/material.dart';
import '../../../data/services/notification_service.dart';

/// Ultra-simple page with just one button to test notifications immediately
class QuickTestPage extends StatelessWidget {
  const QuickTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Notification Test'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_active,
              size: 100,
              color: Colors.purple,
            ),
            const SizedBox(height: 32),
            const Text(
              'Tap the button below to see\nan immediate notification',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 48),

            // Big test button
            ElevatedButton.icon(
              onPressed: () async {
                print('🧪 Testing immediate notification...');
                final success = await NotificationService().showImmediateTestNotification(
                  title: '🎉 Success!',
                  body: 'Your notification system is working perfectly!',
                );

                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Notification sent! Check your notification center.'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('❌ Notification failed! Please enable notifications in Settings.'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                        action: SnackBarAction(
                          label: 'How?',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.rocket_launch, size: 32),
              label: const Text(
                'SHOW NOTIFICATION NOW',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Instructions
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: const Column(
                children: [
                  Text(
                    'What to expect:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• On iOS: Notification appears at the top of the screen\n'
                    '• On macOS: Check the top-right notification center\n'
                    '• The notification appears instantly\n'
                    '• You\'ll see: "🎉 Success!" with a message\n'
                    '• Check console for detailed logs',
                    style: TextStyle(height: 1.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'If notification doesn\'t appear on iOS:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Go to Settings > Notifications\n'
                    '2. Find "Food Tracking" app\n'
                    '3. Enable "Allow Notifications"\n'
                    '4. Enable "Banners" and "Sounds"\n'
                    '5. Restart the app and try again',
                    style: TextStyle(height: 1.5, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

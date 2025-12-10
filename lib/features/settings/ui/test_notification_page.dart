import 'package:flutter/material.dart';
import '../../../test_notifications.dart';

/// A simple test page to manually test notification functions
/// Add this page to your app router to access it easily
class TestNotificationPage extends StatefulWidget {
  const TestNotificationPage({super.key});

  @override
  State<TestNotificationPage> createState() => _TestNotificationPageState();
}

class _TestNotificationPageState extends State<TestNotificationPage> {
  bool _isRunning = false;
  String _lastResult = 'No tests run yet';

  Future<void> _runTest(String testName, Future<void> Function() testFn) async {
    setState(() {
      _isRunning = true;
      _lastResult = 'Running $testName...';
    });

    try {
      await testFn();
      setState(() {
        _lastResult = '✅ $testName completed - Check console logs';
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _lastResult = '❌ $testName failed: $e';
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notifications'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Result Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Result:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_lastResult),
                  if (_isRunning)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Test Buttons
            const Text(
              'Quick Test:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),

            // Immediate notification - highlighted
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.pink[400]!, Colors.purple[400]!],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _TestButton(
                label: '⚡ Show Notification NOW!',
                icon: Icons.notifications_active,
                color: Colors.transparent,
                onPressed: _isRunning
                    ? null
                    : () => _runTest(
                          'Immediate Notification',
                          NotificationTester.testImmediateNotification,
                        ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Individual Tests:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),

            _TestButton(
              label: '1. Schedule Test Notification',
              icon: Icons.notification_add,
              color: Colors.green,
              onPressed: _isRunning
                  ? null
                  : () => _runTest(
                        'Schedule Notification',
                        NotificationTester.testScheduleNotification,
                      ),
            ),

            _TestButton(
              label: '2. Cancel Test Notification',
              icon: Icons.notification_important_outlined,
              color: Colors.orange,
              onPressed: _isRunning
                  ? null
                  : () => _runTest(
                        'Cancel Notification',
                        NotificationTester.testCancelNotification,
                      ),
            ),

            _TestButton(
              label: '3. Reschedule All Notifications',
              icon: Icons.refresh,
              color: Colors.blue,
              onPressed: _isRunning
                  ? null
                  : () => _runTest(
                        'Reschedule All',
                        NotificationTester.testRescheduleAll,
                      ),
            ),

            _TestButton(
              label: '4. Verify All Food Notifications',
              icon: Icons.checklist,
              color: Colors.purple,
              onPressed: _isRunning
                  ? null
                  : () => _runTest(
                        'Verify All Foods',
                        NotificationTester.testVerifyAllFoodNotifications,
                      ),
            ),

            _TestButton(
              label: '5. Send Alerts for Expiring Foods',
              icon: Icons.food_bank,
              color: Colors.teal,
              onPressed: _isRunning
                  ? null
                  : () => _runTest(
                        'Send Expiring Food Alerts',
                        NotificationTester.testShowFoodsNeedingNotification,
                      ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            _TestButton(
              label: 'Run All Tests',
              icon: Icons.play_arrow,
              color: Colors.red,
              onPressed: _isRunning
                  ? null
                  : () => _runTest(
                        'All Tests',
                        NotificationTester.runAllTests,
                      ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Instructions:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Run the app and tap each test button\n'
                    '• Check the console/debug output for detailed logs\n'
                    '• Each test will print its results with emoji markers\n'
                    '• Look for 🔔 (scheduled), 🔕 (cancelled), ✅ (success)',
                    style: TextStyle(fontSize: 13),
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

class _TestButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _TestButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}

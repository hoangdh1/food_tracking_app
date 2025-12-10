import 'package:flutter/material.dart';
import '../../../router/app_router.dart';
import '../../../data/repositories/food_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/models/food_model.dart';
import '../../../data/models/settings_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FoodRepository _foodRepo = FoodRepository();
  final SettingsRepository _settingsRepo = SettingsRepository();

  bool _pushNotificationsEnabled = true;
  bool _dailySummaryEnabled = false;
  double _expiryAlertDays = 3;

  List<FoodItem> _expiringSoonItems = [];
  List<FoodItem> _expiredItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load settings and food items in parallel
      final results = await Future.wait([
        _settingsRepo.getSettings(),
        _foodRepo.getExpiringSoonFoods(daysThreshold: _expiryAlertDays.toInt()),
        _foodRepo.getExpiredFoods(),
      ]);

      final settings = results[0] as AppSettings;
      final expiringSoon = results[1] as List<FoodItem>;
      final expired = results[2] as List<FoodItem>;

      setState(() {
        _pushNotificationsEnabled = settings.enablePushNotifications;
        _dailySummaryEnabled = settings.dailySummaryEnabled;
        _expiryAlertDays = settings.expiryAlertDays.toDouble();
        _expiringSoonItems = expiringSoon;
        _expiredItems = expired;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notification data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePushNotifications(bool value) async {
    setState(() => _pushNotificationsEnabled = value);
    try {
      await _settingsRepo.togglePushNotifications(value);
    } catch (e) {
      print('Error updating push notifications: $e');
    }
  }

  Future<void> _updateDailySummary(bool value) async {
    setState(() => _dailySummaryEnabled = value);
    try {
      await _settingsRepo.toggleDailySummary(value);
    } catch (e) {
      print('Error updating daily summary: $e');
    }
  }

  Future<void> _updateExpiryAlertDays(double value) async {
    setState(() => _expiryAlertDays = value);
    try {
      await _settingsRepo.updateExpiryAlertDays(value.toInt());
      // Reload food items with new threshold
      final results = await Future.wait([
        _foodRepo.getExpiringSoonFoods(daysThreshold: value.toInt()),
        _foodRepo.getExpiredFoods(),
      ]);
      setState(() {
        _expiringSoonItems = results[0] as List<FoodItem>;
        _expiredItems = results[1] as List<FoodItem>;
      });
    } catch (e) {
      print('Error updating expiry alert days: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications & Alerts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNotificationSettings(),
                    const SizedBox(height: 24),
                    _buildProductStatus(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Notification Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingTile(
                icon: Icons.notifications,
                title: 'Enable Push Notifications',
                subtitle: 'Receive alerts for your items',
                value: _pushNotificationsEnabled,
                onChanged: _updatePushNotifications,
                showDivider: true,
              ),
              _buildExpirySlider(),
              _buildSettingTile(
                icon: Icons.calendar_today,
                title: 'Daily Summary Reminder',
                subtitle: 'Get a summary at 09:00 AM',
                value: _dailySummaryEnabled,
                onChanged: _updateDailySummary,
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF333333),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF4CAF50),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: Color(0xFFE0E0E0), indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildExpirySlider() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Expiry Alerts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Text(
                    '${_expiryAlertDays.toInt()} days before',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: const Color(0xFF4CAF50),
                  inactiveTrackColor: const Color(0xFFE0E0E0),
                  thumbColor: const Color(0xFF4CAF50),
                  overlayColor: const Color(0xFF4CAF50).withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: _expiryAlertDays,
                  min: 1,
                  max: 7,
                  divisions: 6,
                  onChanged: _updateExpiryAlertDays,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE0E0E0), indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildProductStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Product Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
        _buildExpiringSoonSection(),
        const SizedBox(height: 16),
        _buildExpiredSection(),
      ],
    );
  }

  Widget _buildExpiringSoonSection() {
    return _buildAccordionSection(
      title: 'Expiring Soon',
      count: _expiringSoonItems.length,
      badgeColor: const Color(0xFFFFC107),
      isExpanded: true,
      items: _expiringSoonItems.map((food) {
        return _buildFoodItem(
          id: food.id,
          name: food.name,
          image: food.imageUrl ?? '',
          statusText: 'Expires in ${food.daysUntilExpiry} days',
          statusColor: const Color(0xFFFFC107),
        );
      }).toList(),
    );
  }

  Widget _buildExpiredSection() {
    return _buildAccordionSection(
      title: 'Expired Items',
      count: _expiredItems.length,
      badgeColor: const Color(0xFFEF5350),
      isExpanded: false,
      items: _expiredItems.map((food) {
        final daysAgo = food.daysUntilExpiry.abs();
        return _buildFoodItem(
          id: food.id,
          name: food.name,
          image: food.imageUrl ?? '',
          statusText: 'Expired $daysAgo ${daysAgo == 1 ? 'day' : 'days'} ago',
          statusColor: const Color(0xFFEF5350),
        );
      }).toList(),
    );
  }

  Widget _buildAccordionSection({
    required String title,
    required int count,
    required Color badgeColor,
    required bool isExpanded,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.only(top: 0, bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          children: items.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No items',
                      style: TextStyle(color: Color(0xFF666666)),
                    ),
                  ),
                ]
              : [
                  const Divider(height: 1, color: Color(0xFFE0E0E0)),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: items,
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  Widget _buildFoodItem({
    required String id,
    required String name,
    required String image,
    required String statusText,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image.isNotEmpty
              ? Image.network(
                  image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported),
                  ),
                )
              : Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.fastfood),
                ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          statusText,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF666666),
        ),
        onTap: () async {
          // Navigate to food detail page and refresh on return
          await Navigator.pushNamed(
            context,
            AppRouter.foodDetail,
            arguments: id,
          );
          _loadData(); // Refresh data after returning
        },
      ),
    );
  }
}

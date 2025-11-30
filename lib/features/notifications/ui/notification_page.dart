import 'package:flutter/material.dart';
import '../../../router/app_router.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _pushNotificationsEnabled = true;
  bool _dailySummaryEnabled = false;
  double _expiryAlertDays = 3;

  final List<Map<String, dynamic>> _expiringSoonItems = [
    {
      'id': 'milk_001',
      'name': 'Organic Milk',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAMGQWFA0Pjvan2GGA19ddOJAUq87Mj2Fr2jvwJTYmGXO6pmAfPaEjx5R_33dcYHhcIWl7J9f_lTxOslunllyKQMqtpI4fNFwCtZDFqMESivoMjzpVfGRqXrBdflsNf165KRQxHVYNlpDvU1yS2FzUKlVMGH4tJgNHuXI2dIAXgnYRAT5TPM6e3IokWnuA-b8LXXvsJOUPLkR-3yeENXLqQhshZGwB9TRaS47sj-C_U7WQsjR7GSx7kZtE5_e2Dcf66F21CRm5YgY8',
      'daysLeft': 2,
    },
    {
      'id': 'salad_002',
      'name': 'Fresh Salad Mix',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDtrke6bl5cH-ZxCmgiOG3RTBGkATy7cZPn_lhCBEACB0TWLEmXKZEgbHzIcdUGS2md4nz15rcZhSC6IBDoo-KKnSdriDUVLWbT5QP8GsxD3BCfNGj9AnCdzScjWQCsGn8r1gsNMYjgoFSUCvmasLZOsD4265hgtVRxAiRUBcWqGrgEgONClNqeUTdIGT0egQeunY6DdqmN-gP41PbGBQwKeOjREVBrYZzFfcTjx4BHzHiEn4ra6uF3t3dKxWATsof4ICWysWuJZPI',
      'daysLeft': 3,
    },
    {
      'id': 'pizza_003',
      'name': 'Leftover Pizza',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBJ-YVK1qqtsjq_LghvYgDil3YArrapk6EH1clqXvmGc12TXeJSG-e1qbKFdbpaj8m1zZvpwPKt98wL6YY5ewdSek9ytLD-I8RyaLU9FHk6P4ior1EJMl0Dfepc12p4fFn2GGCCw2gUavXC6UwvG-XtjZDQmr6OV7aIh4Ahx1Slv6n4kRzK9QgCtBen1Y5s_znFTyAMJbi4-K90p5qBVdqDgzP92d9gvh9TgFWHclulAqmpPMXtzrPrRMectpKH8eSwDp1sgbxH2aI',
      'daysLeft': 4,
    },
  ];

  final List<Map<String, dynamic>> _expiredItems = [
    {
      'id': 'beef_004',
      'name': 'Beef Patties',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDelaazP5q89SX73uriuHL3KqVA3GEdB-lNu_LmhTdCjOQ3WD3FGN6zS4Ay8KjoUVcwbCBAyULV37WHbPePnwQZR19saszXW-TfnvwYb7ZS8DjZ7LFuZm23TSf4DMKeShntiBWLsZWXAhrSoAGDvChZIgF0phHkADrhdEyr7FSPuoE6laIa9NAfsEnYXLTuohBOXpDFILr8BpotNev6LeUETm9ri9J2d-G3s5Jx69taiIBy4PDVVlYb3OpjUSd0SFvnQgIoiwPAz9M',
      'daysAgo': 1,
    },
  ];

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
      body: SingleChildScrollView(
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
                onChanged: (value) {
                  setState(() => _pushNotificationsEnabled = value);
                },
                showDivider: true,
              ),
              _buildExpirySlider(),
              _buildSettingTile(
                icon: Icons.calendar_today,
                title: 'Daily Summary Reminder',
                subtitle: 'Get a summary at 09:00 AM',
                value: _dailySummaryEnabled,
                onChanged: (value) {
                  setState(() => _dailySummaryEnabled = value);
                },
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
                  onChanged: (value) {
                    setState(() => _expiryAlertDays = value);
                  },
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
      items: _expiringSoonItems.map((item) {
        return _buildFoodItem(
          id: item['id'] as String,
          name: item['name'] as String,
          image: item['image'] as String,
          statusText: 'Expires in ${item['daysLeft']} days',
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
      items: _expiredItems.map((item) {
        return _buildFoodItem(
          id: item['id'] as String,
          name: item['name'] as String,
          image: item['image'] as String,
          statusText: 'Expired ${item['daysAgo']} day ago',
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
          children: [
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
          child: Image.network(
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
        onTap: () {
          // Navigate to food detail page with the food ID
          Navigator.pushNamed(
            context,
            AppRouter.foodDetail,
            arguments: id,
          );
        },
      ),
    );
  }
}
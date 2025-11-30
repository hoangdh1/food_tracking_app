import 'package:flutter/material.dart';
import '../../../router/app_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedFilterIndex = 0;

  final List<Map<String, dynamic>> mockFoods = [
    {
      'name': 'Milk',
      'category': 'Dairy',
      'qty': '1L',
      'days': 12,
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAt4jsbJ0YBb7NandmvZsrTQYHNbtnedcNHGBQaz7UVOlrMw7AO-bxdPNuuY7um6KfhwpGgYgBYjNaAgbnF2eBqc3bXC4tUFMlrkuBv301MsFR6G2Ji3B1TUrKHA4q084eHUcYIC54qCLvz8DiRPlDlfjLoGQboWXov90ZUU0nMq71Hi8kdN2s2927b9D4Vs8rV6XswtRpejk4wy9ORGfQyrmt700pgBYQ4ZI21BPUHzSQeYD0jkbwvY5YEXIQ4ZEiVNXSNUBnNKaQ',
      'status': 'green',
    },
    {
      'name': 'Chicken Breast',
      'category': 'Meat',
      'qty': '500g',
      'days': 3,
      'image': '',
      'status': 'orange',
    },
    {
      'name': 'Lettuce',
      'category': 'Vegetable',
      'qty': '1 head',
      'days': -1,
      'image': '',
      'status': 'red',
    },
    {
      'name': 'Apples',
      'category': 'Fruit',
      'qty': '6 pcs',
      'days': 8,
      'image': '',
      'status': 'green',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        title: const Text(
          "Food Inventory",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildSummaryCards(),
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildFilterChips(),
            const SizedBox(height: 12),
            _buildFoodList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          _SummaryCard(title: "Total Items", count: "32", color: Colors.black),
          SizedBox(width: 8),
          _SummaryCard(
            title: "Expiring Soon",
            count: "5",
            color: Colors.orange,
          ),
          SizedBox(width: 8),
          _SummaryCard(title: "Expired", count: "2", color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: "Search for an item...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ["All", "Expiring Soon", "Expired", "Category"];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = selectedFilterIndex == index;
          return ChoiceChip(
            label: Text(filters[index]),
            selected: isSelected,
            onSelected: (_) => setState(() => selectedFilterIndex = index),
            selectedColor: Colors.green.shade200,
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
      ),
    );
  }

  Widget _buildFoodList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockFoods.length,
      itemBuilder: (context, index) {
        final food = mockFoods[index];
        final days = food['days'];

        String statusText;
        Color statusColor = _getStatusColor(food['status']);

        if (days < 0) {
          statusText = "Expired";
        } else if (days == 0) {
          statusText = "Expires today";
        } else {
          statusText = "$days days left";
        }
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: statusColor, width: 4)),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  food['image'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, _) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              title: Text(
                food['name'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${food['category']} • ${food['qty']}"),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to food detail page
                Navigator.pushNamed(
                  context,
                  AppRouter.foodDetail,
                  arguments: 'food_$index', // Pass the food ID
                );
              },
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        switch (index) {
        case 0:
          // Already on home
          break;
        case 1:
          // Navigate to Add Food
          Navigator.pushNamed(context, AppRouter.addFood);
          break;
        case 2:
          // TODO: Navigate to Shopping List
          break;
        case 3:
          // Navigate to Notifications
          Navigator.pushNamed(context, AppRouter.notifications);
          break;
        case 4:
          // TODO: Navigate to Settings
          break;
      }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.inventory_2),
          label: "Inventory",
        ),
        NavigationDestination(icon: Icon(Icons.add_box), label: "Add"),
        NavigationDestination(
          icon: Icon(Icons.shopping_cart),
          label: "Shopping",
        ),
        NavigationDestination(icon: Icon(Icons.notifications), label: "Alerts"),
        NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

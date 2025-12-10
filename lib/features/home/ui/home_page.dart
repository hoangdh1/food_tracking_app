import 'package:flutter/material.dart';
import '../../../router/app_router.dart';
import '../../../data/repositories/food_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/models/food_model.dart';
import '../../../data/models/category_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedFilterIndex = 0;

  final FoodRepository _foodRepo = FoodRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final SettingsRepository _settingsRepo = SettingsRepository();

  List<FoodItem> allFoods = []; // All foods from database
  List<FoodItem> filteredFoods = []; // Filtered foods to display
  Map<String, String> categoryMap = {}; // categoryId -> categoryName
  bool isLoading = true;

  // Search controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Statistics
  int totalItems = 0;
  int expiringSoonCount = 0;
  int expiredCount = 0;
  int expiryAlertDays = 5; // Default, will be loaded from settings

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load foods, categories, and settings in parallel
      final results = await Future.wait([
        _foodRepo.getAllFoods(),
        _categoryRepo.getCategoriesMap(),
        _settingsRepo.getSettings(),
      ]);

      final loadedFoods = results[0] as List<FoodItem>;
      final categories = results[1] as Map<String, Category>;
      final settings = results[2] as dynamic;

      setState(() {
        allFoods = loadedFoods;
        categoryMap = categories.map((id, cat) => MapEntry(id, cat.name));
        expiryAlertDays = settings.expiryAlertDays as int;
        _calculateStatistics();
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _calculateStatistics() {
    totalItems = allFoods.length;
    expiringSoonCount = 0;
    expiredCount = 0;

    final now = DateTime.now();

    for (var food in allFoods) {
      final days = food.expiryDate.difference(now).inDays;
      if (days < 0) {
        expiredCount++;
      } else if (days <= expiryAlertDays) {
        expiringSoonCount++;
      }
    }
  }

  void _applyFilters() {
    List<FoodItem> result = List.from(allFoods);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((food) {
        return food.name.toLowerCase().contains(query) ||
            _getCategoryName(food.categoryId).toLowerCase().contains(query);
      }).toList();
    }

    // Apply chip filter
    final now = DateTime.now();
    switch (selectedFilterIndex) {
      case 0: // All
        // Show all (already in result)
        break;
      case 1: // Expiring Soon
        result = result.where((food) {
          final days = food.expiryDate.difference(now).inDays;
          return days >= 0 && days <= expiryAlertDays;
        }).toList();
        break;
      case 2: // Expired
        result = result.where((food) {
          return food.expiryDate.difference(now).inDays < 0;
        }).toList();
        break;
      case 3: // Category (show all for now, could open category picker)
        // For now, just show all. You could implement category selection here
        break;
    }

    setState(() {
      filteredFoods = result;
    });
  }

  String _getCategoryName(String categoryId) {
    return categoryMap[categoryId] ?? 'Unknown';
  }

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
        actions: [
          // Quick test notification button
          IconButton(
            icon: const Icon(Icons.notification_add),
            tooltip: 'Test Notification',
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.quickTest);
            },
          ),
        ],
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
        children: [
          _SummaryCard(
            title: "Total Items",
            count: totalItems.toString(),
            color: Colors.black,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            title: "Expiring Soon",
            count: expiringSoonCount.toString(),
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            title: "Expired",
            count: expiredCount.toString(),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: "Search for an item...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
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
            onSelected: (_) {
              setState(() {
                selectedFilterIndex = index;
                _applyFilters();
              });
            },
            selectedColor: Colors.green.shade200,
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
      ),
    );
  }

  Widget _buildFoodList() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (filteredFoods.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? "No items match your search"
                    : "No food items found",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredFoods.length,
      itemBuilder: (context, index) {
        final food = filteredFoods[index];
        final days = food.expiryDate.difference(DateTime.now()).inDays;
        final category = _getCategoryName(food.categoryId);

        Color statusColor;
        String statusText;

        if (days < 0) {
          statusColor = Colors.red;
          statusText = "Expired";
        } else if (days <= expiryAlertDays) {
          statusColor = Colors.orange;
          statusText = "$days days left";
        } else {
          statusColor = Colors.green;
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
                child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                    ? Image.network(
                        food.imageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, _) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.fastfood),
                      ),
              ),
              title: Text(
                food.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${category} • ${food.quantity}"),
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
              onTap: () async {
                // Navigate to food detail page and refresh on return
                await Navigator.pushNamed(
                  context,
                  AppRouter.foodDetail,
                  arguments: food.id,
                );
                _loadData(); // Refresh data after returning
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
      onDestinationSelected: (index) async {
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            // Navigate to Add Food and refresh on return
            await Navigator.pushNamed(context, AppRouter.addFood);
            _loadData(); // Refresh data after returning
            break;
          case 2:
            // TODO: Navigate to Shopping List
            break;
          case 3:
            // Navigate to Test Notifications page
            Navigator.pushNamed(context, AppRouter.testNotifications);
            break;
          case 4:
            // TODO: Navigate to Notifications Settings
            Navigator.pushNamed(context, AppRouter.notifications);
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

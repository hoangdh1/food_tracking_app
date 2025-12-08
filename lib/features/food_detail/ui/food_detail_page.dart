import 'package:flutter/material.dart';
import 'widgets/delete_confirmation_dialog.dart';
import '../../../data/repositories/food_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/models/food_model.dart';
import '../../../data/models/category_model.dart';

enum FoodDetailMode { view, edit }

class FoodDetailPage extends StatefulWidget {
  final String foodId;

  const FoodDetailPage({super.key, required this.foodId});

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  final FoodRepository _foodRepo = FoodRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  
  FoodDetailMode _mode = FoodDetailMode.view;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  
  // Data
  FoodItem? _foodItem;
  List<Category> _categories = [];
  Map<String, Category> _categoriesMap = {};
  String? _selectedCategoryId;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  int _notificationThreshold = 3;
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      print('🔍 Loading food detail for ID: ${widget.foodId}');
      
      // Load food item and categories in parallel
      final results = await Future.wait([
        _foodRepo.getFoodById(widget.foodId),
        _categoryRepo.getAllCategories(),
      ]);
      
      final foodItem = results[0] as FoodItem?;
      final categories = results[1] as List<Category>;
      
      if (foodItem == null) {
        throw Exception('Food item not found');
      }
      
      // Create categories map
      final categoriesMap = <String, Category>{};
      for (var cat in categories) {
        categoriesMap[cat.id] = cat;
      }
      
      // Set form data
      _nameController.text = foodItem.name;
      _quantityController.text = foodItem.quantity.toString();
      _selectedCategoryId = foodItem.categoryId;
      _expiryDate = foodItem.expiryDate;
      _notificationThreshold = foodItem.notificationThreshold;
      
      setState(() {
        _foodItem = foodItem;
        _categories = categories;
        _categoriesMap = categoriesMap;
        _isLoading = false;
      });
      
      print('✅ Food item loaded: ${foodItem.name}');
    } catch (e) {
      print('❌ Error loading food detail: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading food: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == FoodDetailMode.view
          ? FoodDetailMode.edit
          : FoodDetailMode.view;
    });
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        onConfirm: _deleteFood,
      ),
    );
  }

  Future<void> _deleteFood() async {
    try {
      print('🗑️ Deleting food: ${widget.foodId}');
      
      await _foodRepo.deleteFood(widget.foodId);
      
      print('✅ Food deleted successfully');
      
      if (mounted) {
        Navigator.pop(context); // Close dialog
        Navigator.pop(context, true); // Go back to home with success flag
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error deleting food: $e');
      
      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_foodItem == null || _selectedCategoryId == null) {
      return;
    }
    
    setState(() => _isSaving = true);
    
    try {
      print('💾 Saving changes for food: ${widget.foodId}');
      
      // Parse quantity
      int quantity = 1;
      try {
        quantity = int.parse(_quantityController.text);
      } catch (e) {
        quantity = _foodItem!.quantity;
      }
      
      // Create updated food item
      final updatedFood = _foodItem!.copyWith(
        name: _nameController.text.trim(),
        quantity: quantity,
        categoryId: _selectedCategoryId,
        expiryDate: _expiryDate,
        notificationThreshold: _notificationThreshold,
        updatedAt: DateTime.now(),
      );
      
      await _foodRepo.updateFood(widget.foodId, updatedFood);
      
      print('✅ Food updated successfully');
      
      // Reload data
      await _loadData();
      
      setState(() {
        _mode = FoodDetailMode.view;
        _isSaving = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving changes: $e');
      
      setState(() => _isSaving = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving changes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _getDaysUntilExpiry() {
    final now = DateTime.now();
    return _expiryDate.difference(now).inDays;
  }

  String _getExpiryText() {
    final days = _getDaysUntilExpiry();
    if (days < 0) return 'Expired ${days.abs()} days ago';
    if (days == 0) return 'Expires today';
    return 'Expires in $days days';
  }

  Color _getExpiryColor() {
    final days = _getDaysUntilExpiry();
    if (days < 0) return const Color(0xFFD32F2F);
    if (days <= _notificationThreshold) return const Color(0xFFFFC107);
    return const Color(0xFF4CAF50);
  }

  String _getCategoryName() {
    if (_selectedCategoryId == null) return 'Unknown';
    return _categoriesMap[_selectedCategoryId]?.name ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF8F9FA).withOpacity(0.8),
          foregroundColor: const Color(0xFF212529),
          title: const Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_foodItem == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF8F9FA).withOpacity(0.8),
          foregroundColor: const Color(0xFF212529),
          title: const Text('Error'),
        ),
        body: const Center(child: Text('Food item not found')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FA).withOpacity(0.8),
        foregroundColor: const Color(0xFF212529),
        centerTitle: true,
        title: Text(
          _mode == FoodDetailMode.view ? 'Item Details' : 'Edit Item',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 180,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 24),
                  _mode == FoodDetailMode.view
                      ? _buildViewMode()
                      : _buildEditMode(),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _foodItem!.imageUrl.isNotEmpty
              ? Image.network(
                  _foodItem!.imageUrl,
                  height: 256,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                )
              : _buildPlaceholderImage(),
        ),
        if (_mode == FoodDetailMode.edit)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image picker coming soon')),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 256,
      color: Colors.grey.shade300,
      child: const Icon(Icons.fastfood, size: 64, color: Colors.grey),
    );
  }

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _foodItem!.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212529),
          ),
        ),
        const SizedBox(height: 16),
        _buildExpiryBanner(),
        const SizedBox(height: 24),
        _buildInfoGrid(),
      ],
    );
  }

  Widget _buildEditMode() {
    return Column(
      children: [
        _buildTextField(
          label: 'Item Name',
          controller: _nameController,
          hint: 'e.g., Organic Avocados',
        ),
        const SizedBox(height: 20),
        _buildCategoryDropdown(),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Quantity',
                controller: _quantityController,
                hint: 'e.g., 2',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDatePicker(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildNotificationThresholdSlider(),
        const SizedBox(height: 16),
        _buildExpiryBanner(),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF495057),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF495057),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDEE2E6)),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCategoryId,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategoryId = value),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expiry Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF495057),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _expiryDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() => _expiryDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDEE2E6)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_expiryDate.month}/${_expiryDate.day}/${_expiryDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Icon(Icons.calendar_today, color: Color(0xFF495057)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationThresholdSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Alert Before Expiry',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF495057),
              ),
            ),
            Text(
              '$_notificationThreshold days',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF4CAF50),
            inactiveTrackColor: const Color(0xFFE0E0E0),
            thumbColor: const Color(0xFF4CAF50),
            overlayColor: const Color(0xFF4CAF50).withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            trackHeight: 4,
          ),
          child: Slider(
            value: _notificationThreshold.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            label: '$_notificationThreshold days',
            onChanged: (value) {
              setState(() => _notificationThreshold = value.toInt());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryBanner() {
    final expiryColor = _getExpiryColor();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: expiryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_top, color: expiryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            _getExpiryText(),
            style: TextStyle(
              color: expiryColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildInfoCard('Quantity', _foodItem!.quantity.toString()),
        _buildInfoCard(
          'Expiry Date',
          '${_expiryDate.month}/${_expiryDate.day}/${_expiryDate.year}',
        ),
        _buildInfoCard('Category', _getCategoryName()),
        _buildInfoCard('Alert Days', '${_foodItem!.notificationThreshold} days'),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDEE2E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6C757D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212529),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA).withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_mode == FoodDetailMode.view) ...[
              ElevatedButton(
                onPressed: _toggleMode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Edit Item',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _showDeleteDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD32F2F),
                  side: BorderSide.none,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Delete Item',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 4,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _showDeleteDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD32F2F),
                  side: BorderSide.none,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Delete Item',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
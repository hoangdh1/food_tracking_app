import 'package:flutter/material.dart';
import '../../../data/repositories/food_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/models/food_model.dart';
import '../../../data/models/category_model.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({Key? key}) : super(key: key);

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  // Repositories
  final FoodRepository _foodRepo = FoodRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  String _selectedCategory = 'Select a category';
  DateTime? _expiryDate;
  String _selectedStorage = 'fridge';
  int _quantity = 1;
  
  // For mapping category names to IDs
  Map<String, String> _categoryMap = {}; // name -> id
  bool _isLoadingCategories = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
  print('🔍 DEBUG: Loading categories...');
  try {
    final categories = await _categoryRepo.getAllCategories();
    print('✅ DEBUG: Loaded ${categories.length} categories');
    for (var cat in categories) {
      print('  - ${cat.name} (ID: ${cat.id})');
    }
    
    setState(() {
      _categoryMap = {
        for (var category in categories) category.name: category.id
      };
      _isLoadingCategories = false;
    });
    
    print('🔍 DEBUG: Category map created: $_categoryMap');
  } catch (e, stackTrace) {
    print('❌ DEBUG: Error loading categories');
    print('❌ ERROR: $e');
    print('❌ STACK TRACE: $stackTrace');
    setState(() {
      _isLoadingCategories = false;
    });
  }
}

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) _quantity--;
    });
  }

Future<void> _addItem() async {
  print('🐛 DEBUG: _addItem called');
  
  // Validate form
  if (!_formKey.currentState!.validate()) {
    print('❌ DEBUG: Form validation failed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all required fields')),
    );
    return;
  }
  print('✅ DEBUG: Form validated');

  if (_selectedCategory == 'Select a category') {
    print('❌ DEBUG: No category selected');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a category')),
    );
    return;
  }
  print('✅ DEBUG: Category selected: $_selectedCategory');

  if (_expiryDate == null) {
    print('❌ DEBUG: No expiry date selected');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select an expiry date')),
    );
    return;
  }
  print('✅ DEBUG: Expiry date selected: $_expiryDate');

  setState(() {
    _isSaving = true;
  });

  try {
    print('🔍 DEBUG: Category map: $_categoryMap');
    
    // Get category ID from selected category name
    final categoryId = _categoryMap[_selectedCategory];
    print('🔍 DEBUG: Category ID: $categoryId');
    
    if (categoryId == null) {
      print('❌ DEBUG: Category ID is null!');
      throw Exception('Category not found');
    }

    // Create new food item
    final now = DateTime.now();
    final newFood = FoodItem(
      id: '',
      name: _itemNameController.text.trim(),
      quantity: _quantity,
      expiryDate: _expiryDate!,
      categoryId: categoryId,
      source: 'manual',
      imageUrl: '',
      notificationThreshold: 3,
      createdAt: now,
      updatedAt: now,
    );

    print('🔍 DEBUG: Food item created:');
    print('  - Name: ${newFood.name}');
    print('  - Quantity: ${newFood.quantity}');
    print('  - Category ID: ${newFood.categoryId}');
    print('  - Expiry Date: ${newFood.expiryDate}');
    
    print('📤 DEBUG: Calling _foodRepo.addFood...');
    
    // Save to Firestore
    final foodId = await _foodRepo.addFood(newFood);
    
    print('✅ DEBUG: Food item created successfully with ID: $foodId');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item added successfully! ID: $foodId'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, true);
    }
  } catch (e, stackTrace) {
    print('❌ DEBUG: Error adding food item');
    print('❌ ERROR: $e');
    print('❌ STACK TRACE: $stackTrace');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1d1d1d) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF2a2a2a) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Item',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark 
              ? const Color(0xFF424242).withOpacity(0.5)
              : const Color(0xFFBDBDBD).withOpacity(0.5),
          ),
        ),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Item Name
                  _buildSectionLabel('Item Name'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _itemNameController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Organic Milk',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2a2a2a) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF4CAF50),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter item name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category
                  _buildSectionLabel('Category'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2a2a2a) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF4CAF50),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    items: [
                      'Select a category',
                      ..._categoryMap.keys.toList()..sort(),
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Expiry Date
                  _buildSectionLabel('Expiry Date'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2a2a2a) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
                          ),
                        ),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: isDark 
                            ? const Color(0xFFe0e0e0).withOpacity(0.7)
                            : const Color(0xFF424242).withOpacity(0.7),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      child: Text(
                        _expiryDate == null
                            ? 'Select a date'
                            : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                        style: TextStyle(
                          color: _expiryDate == null
                              ? (isDark ? const Color(0xFF757575) : const Color(0xFFBDBDBD))
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Storage Location
                  _buildSectionLabel('Storage Location'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStorageOption(
                          'fridge',
                          Icons.kitchen,
                          'Fridge',
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStorageOption(
                          'pantry',
                          Icons.inventory_2,
                          'Pantry',
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStorageOption(
                          'freezer',
                          Icons.ac_unit,
                          'Freezer',
                          isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quantity
                  _buildSectionLabel('Quantity'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2a2a2a) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _decrementQuantity,
                          icon: Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1d1d1d) : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.remove,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: _incrementQuantity,
                          icon: Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1d1d1d) : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.add,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Add Photo
                  _buildSectionLabel('Add Photo (Optional)'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      // TODO: Add photo functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Photo upload coming soon!')),
                      );
                    },
                    child: Container(
                      height: 128,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2a2a2a) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: isDark ? const Color(0xFF757575) : const Color(0xFFBDBDBD),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add photo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF757575) : const Color(0xFFBDBDBD),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF2a2a2a) : Colors.white).withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _addItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                    'Add Item',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildStorageOption(String value, IconData icon, String label, bool isDark) {
    final isSelected = _selectedStorage == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStorage = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
            ? const Color(0xFF4CAF50)
            : (isDark ? const Color(0xFF2a2a2a) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? const Color(0xFF4CAF50)
              : (isDark ? const Color(0xFF424242) : const Color(0xFFBDBDBD)),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected 
                ? Colors.white
                : (isDark ? const Color(0xFFe0e0e0) : const Color(0xFF424242)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
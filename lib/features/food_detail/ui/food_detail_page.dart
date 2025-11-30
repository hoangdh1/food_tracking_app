import 'package:flutter/material.dart';
import 'widgets/delete_confirmation_dialog.dart';

enum FoodDetailMode { view, edit }

class FoodDetailPage extends StatefulWidget {
  final String foodId;

  const FoodDetailPage({super.key, required this.foodId});

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  FoodDetailMode _mode = FoodDetailMode.view;

  // Form controllers
  final _nameController = TextEditingController(text: 'Organic Avocados');
  final _quantityController = TextEditingController(text: '2');
  String _category = 'Produce';
  String _storage = 'Fridge';
  DateTime _expiryDate = DateTime(2024, 10, 28);

  // Mock data
  final String _imageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDVlcq7YhPTsr4_e71pvHbgXCVXmvGW8bH93QAQ3GftUUvF121RzDdeDlUqYe9wHS5sG-bJBORyaKtbdE9eiZCwbmJiN8aM4jh9ySw52TeJckfT0sGqf_MM2OT8DgtetB490bWj2NztYC_czTNHesxO7r43JlExmAawR18w4rWWBStSmWsV_apDhpBLuRyNFXpA-7w-_QOMVNiAdRs4D6uBVUdMkBliTpp3irGlCgT-0Xi1Wm1ShZ2xaCBqplH7R3zq_OHBrzUH9qA';

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
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
        onConfirm: () {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Go back to home
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted successfully')),
          );
        },
      ),
    );
  }

  void _saveChanges() {
    // TODO: Implement save logic
    setState(() {
      _mode = FoodDetailMode.view;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved successfully')),
    );
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
    if (days <= 5) return const Color(0xFFFFC107);
    return const Color(0xFF4CAF50);
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => Navigator.pop(context),
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
          child: Image.network(
            _imageUrl,
            height: 256,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 256,
              color: Colors.grey.shade300,
              child: const Icon(Icons.image_not_supported, size: 64),
            ),
          ),
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
                  // TODO: Implement image picker
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

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _nameController.text,
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
        _buildDropdown(
          label: 'Category',
          value: _category,
          items: ['Dairy', 'Produce', 'Pantry', 'Meat', 'Bakery'],
          onChanged: (value) => setState(() => _category = value!),
        ),
        const SizedBox(height: 20),
        _buildDropdown(
          label: 'Storage Location',
          value: _storage,
          items: ['Fridge', 'Freezer', 'Pantry'],
          onChanged: (value) => setState(() => _storage = value!),
        ),
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDEE2E6)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
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
        _buildInfoCard('Quantity', _quantityController.text),
        _buildInfoCard(
          'Expiry Date',
          '${_expiryDate.month}/${_expiryDate.day}/${_expiryDate.year}',
        ),
        _buildInfoCard('Category', _category),
        _buildInfoCard('Storage', _storage),
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
                onPressed: _saveChanges,
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
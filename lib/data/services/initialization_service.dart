import '../repositories/category_repository.dart';
import '../repositories/settings_repository.dart';

class InitializationService {
  final CategoryRepository _categoryRepo = CategoryRepository();
  final SettingsRepository _settingsRepo = SettingsRepository();

  Future<void> initializeApp() async {
    try {
      print('🚀 Initializing app...');
      
      // Initialize categories
      // await _categoryRepo.initializeDefaultCategories();
      
      // Initialize settings (will create if not exists)
      // await _settingsRepo.getSettings();
      
      print('✅ App initialized successfully');
    } catch (e) {
      print('❌ Error initializing app: $e');
      rethrow;
    }
  }
}
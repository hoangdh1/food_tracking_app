import 'package:flutter/material.dart';
import 'package:food_tracking/firebase_options.dart';
import 'router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/services/initialization_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔥 Step 1: Initializing Firebase...');
  print(
    '✅ DefaultFirebaseOptions.currentPlatform: ${DefaultFirebaseOptions.currentPlatform}',
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('✅ Firebase initialized');

  print('🔥 Step 2: Configuring Firestore...');
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  print('✅ Firestore configured');
  print(
    '   - Persistence: ${FirebaseFirestore.instance.settings.persistenceEnabled}',
  );
  print(
    '   - Cache size: ${FirebaseFirestore.instance.settings.cacheSizeBytes}',
  );

  print('🔥 Step 3: Initializing app data...');
  await InitializationService().initializeApp();

  print('✅ App initialization complete\n');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Tracker',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

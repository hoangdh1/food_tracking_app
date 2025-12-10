import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:food_tracking/firebase_options.dart';
import 'router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/services/initialization_service.dart';
import 'data/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔥 Step 1: Initializing Firebase...');
  // print(
  //   '✅ DefaultFirebaseOptions.currentPlatform: ${DefaultFirebaseOptions.currentPlatform}',
  // );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('✅ Firebase initialized');

  print('🔥 Step 2: Configuring Firestore...');
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: false,
    // cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  print('✅ Firestore configured');
  // print(
  //   '   - Persistence: ${FirebaseFirestore.instance.settings.persistenceEnabled}',
  // );
  // print(
  //   '   - Cache size: ${FirebaseFirestore.instance.settings.cacheSizeBytes}',
  // );

  print('🔥 Step 3: Initializing notification service...');
  await NotificationService().initialize();

  print('🔥 Step 4: Initializing app data...');
  await InitializationService().initializeApp();

  print('🔥 Step 5: Scheduling notifications for existing foods...');
  await NotificationService().rescheduleAllNotifications();

  // print('🔥 Step x: Testing Firestore connection...');
  // try {
  //   // Debug: Check Firebase app configuration
  //   print('📱 Platform: $defaultTargetPlatform');
  //   print('🔑 Project ID: ${Firebase.app().options.projectId}');
  //   print('🔑 App ID: ${Firebase.app().options.appId}');

  //   // Test 1: Force fetch from SERVER (not cache)
  //   print('🌐 Forcing server fetch...');
  //   final testDoc = await FirebaseFirestore.instance
  //       .collection('categories')
  //       .limit(1)
  //       .get(const GetOptions(source: Source.server));
  //   print('✅ Server query - Documents: ${testDoc.docs.length}');
  //   print('📊 Query metadata - fromCache: ${testDoc.metadata.isFromCache}');

  //   // Test 2: Check if we can see the document data
  //   if (testDoc.docs.isNotEmpty) {
  //     print('✅ Document data: ${testDoc.docs.first.data()}');
  //   } else {
  //     print('⚠️  No documents returned from server query');
  //   }

  //   // Test 3: Get all documents from SERVER
  //   final allDocs = await FirebaseFirestore.instance
  //       .collection('categories')
  //       .get(const GetOptions(source: Source.server));
  //   print('✅ All documents count (server): ${allDocs.docs.length}');
  //   print('📊 All docs metadata - fromCache: ${allDocs.metadata.isFromCache}');

  //   // Test 4: List all document IDs
  //   if (allDocs.docs.isNotEmpty) {
  //     print('📄 Document IDs:');
  //     for (var doc in allDocs.docs) {
  //       print('   - ${doc.id}: ${doc.data()}');
  //     }
  //   }
  // } catch (e) {
  //   print('❌ Firestore connection failed: $e');
  //   print('Error type: ${e.runtimeType}');
  //   print('Stack trace: $e');
  // }

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

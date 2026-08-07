import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'app.dart';
import 'services/settings_service.dart';
import 'services/ai_memory_service.dart';
import 'services/budget_service.dart';
import 'services/habit_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
    debugPrint('[FIREBASE] Successfully initialized Firebase Core & Cloud Firestore!');
  } catch (e) {
    debugPrint('[FIREBASE] Error initializing Firebase Core: $e');
  }

  // Initialize Core Services
  await SettingsService.instance.load();
  await AiMemoryService.instance.init();
  await BudgetService.instance.init();
  await HabitService.instance.init();

  runApp(const LifemateApp());
}

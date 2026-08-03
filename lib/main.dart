import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'app.dart';
import 'services/settings_service.dart';

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

  // Initialize Settings Service with Cloud Sync
  await SettingsService.instance.load();

  runApp(const LifemateApp());
}

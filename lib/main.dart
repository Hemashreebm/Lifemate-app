import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint('[FIREBASE] Successfully initialized Firebase Core!');
  } catch (e) {
    debugPrint('[FIREBASE] Error initializing Firebase Core: $e');
  }
  runApp(const LifemateApp());
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app.dart';

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
  runApp(const LifemateApp());
}

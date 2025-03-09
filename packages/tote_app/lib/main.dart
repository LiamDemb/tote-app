import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tote_app/widgets/auth_wrapper.dart';
import 'package:tote_app/config/api_config.dart';
import 'firebase_options.dart';
import 'package:tote_app/theme/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Load any saved API URL override
  await ApiConfig.loadSavedOverrideUrl();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Tote',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

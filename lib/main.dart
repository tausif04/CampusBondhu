import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusbondhu/config/router.dart';
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // firebase_options.dart still has placeholder values.
    // The app will launch but Firebase calls won't work until you
    // replace the values in firebase_options.dart with your real project config.
    debugPrint('⚠️  Firebase init failed: $e');
    debugPrint(
        '👉  Replace the values in lib/firebase_options.dart with your '
        'real Firebase project config, or run: flutterfire configure');
  }

  runApp(const ProviderScope(child: CampusBondhuApp()));
}

class CampusBondhuApp extends ConsumerWidget {
  const CampusBondhuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CampusBondhu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}

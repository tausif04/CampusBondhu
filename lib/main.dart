import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/theme/theme_provider.dart';

import 'features/auth/presentation/login_page.dart';
import 'features/home/presentation/home_page.dart';
import 'features/auth/presentation/register_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusBondhu',

      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,

      initialRoute: '/login',

      routes: <String, WidgetBuilder>{
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}
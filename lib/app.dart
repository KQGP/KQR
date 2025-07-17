import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/home_screen.dart';
import 'theme/app_theme.dart';

final themeProvider = ChangeNotifierProvider((ref) => AppTheme());

class KqrApp extends ConsumerWidget {
  const KqrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'KQR',
      theme: theme.getLightTheme(),
      darkTheme: theme.getDarkTheme(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
} 
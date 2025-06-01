import 'package:flutter/material.dart';
import 'package:mobile_ai_project/appbar_provider.dart';
import 'package:provider/provider.dart';

import 'screens/main_screen.dart';
   
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppBarThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppBarThemeProvider>(context);

    if (!provider.isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Debug banner'ı gizle

      themeMode: provider.themeMode,
      // açık/koyu mod seçimi buradan yapılır. Provider'dan alınır.

      theme: ThemeData(
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: provider.appBarColor,
          // AppBar rengi burada ayarlanır. Provider'dan alınır
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      // Açık tema için ayarlanır.

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: provider.appBarColor,
        ),
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

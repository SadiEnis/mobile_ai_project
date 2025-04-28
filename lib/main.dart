import 'package:flutter/material.dart';
import 'screens/main_screen.dart'; // Eğer main_screen.dart farklı bir yerdeyse yolu ayarla.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gardırop Uygulaması',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor:
            Colors.blueGrey.shade900, // Buğulu cam arka planı için
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

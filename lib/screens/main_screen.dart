// lib/screens/main_screen.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isLoggedIn = false;
  String _username = '';
  String _gender = '';

  List<String> dummyCombinations = [
    "Kombin 1",
    "Kombin 2",
    "Kombin 3",
    "Kombin 4",
    "Kombin 5",
    "Kombin 6",
    "Kombin 7",
  ];

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_data.txt');

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final parts = content.split(',');
        setState(() {
          _username = parts[0];
          _gender = parts[1];
          _isLoggedIn = true;
        });
      }
    }
  }

  Future<void> _saveUser(String name, String gender) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_data.txt');
    await file.writeAsString('$name,$gender');

    setState(() {
      _username = name;
      _gender = gender;
      _isLoggedIn = true;
    });
  }

  void _selectGender(String gender) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('İsmini Gir'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'İsmin'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveUser(nameController.text.trim(), gender);
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoggedIn ? _buildHomePage() : _buildLoginPage(),
      floatingActionButton: _isLoggedIn
          ? FloatingActionButton(
              onPressed: () {
                // Kıyafet ekle aksiyonu (sonra yapılacak)
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildLoginPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Cinsiyet Seçin',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _genderButton('Kadın', Colors.pink),
              const SizedBox(width: 20),
              _genderButton('Erkek', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _genderButton(String gender, Color color) {
    return ElevatedButton(
      onPressed: () => _selectGender(gender),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        gender,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Hoş geldin, $_username!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: dummyCombinations.length,
                itemBuilder: (context, index) {
                  final kombin = dummyCombinations[index];
                  return _frostedCard(kombin);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _frostedCard(String text) {
    return GestureDetector(
      onTap: () {
        // Kombin detay sayfasına git (sonra yapılacak)
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

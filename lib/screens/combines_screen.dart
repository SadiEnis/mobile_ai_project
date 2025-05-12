import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_ai_project/appbar_provider.dart';
import 'package:mobile_ai_project/screens/combine_detail_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class CombinesScreen extends StatefulWidget {
  const CombinesScreen({super.key});

  @override
  State<CombinesScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<CombinesScreen> {
  List<Map<String, dynamic>> _combinations = [];

  Future<List<Map<String, dynamic>>> loadCombinations() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/combines.json');
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gardırobum'),
        backgroundColor: context.watch<AppBarThemeProvider>().appBarColor,
      ),
      // Drawer ekledik. Kullanıcı giriş yapmışsa görünmesini istedik ve kullanıcının yapabileceği işlemleri tek bir bardan görsün istedik.
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Expanded(
          child: ListView.builder(
            itemCount: _combinations.length,
            itemBuilder: (context, index) {
              final kombin = _combinations[index];
              return _frostedCard(
                kombin['name'] ?? 'Kombin',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CombineDetailScreen(combination: kombin),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    ); // Giriş yapmamışsa cinsiyet seçme ekranı ve isim girme ekranı gelecek.
  }

  @override
  void initState() {
    super.initState();
    loadCombinations().then((data) {
      setState(() {
        _combinations = data;
      });
    });
  }

  Widget _frostedCard(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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

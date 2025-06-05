import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_ai_project/appbar_provider.dart';
import 'package:mobile_ai_project/screens/combine_detail_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

//  Bu ekran, kullanıcıların kaydettikleri kombinleri görüntülemesine olanak tanır.
//  Kullanıcı, kombinleri listeleyebilir ve her bir kombin için detayları görüntüleyebilir.

class CombinesScreen extends StatefulWidget {
  const CombinesScreen({super.key});

  @override
  State<CombinesScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<CombinesScreen> {
  List<Map<String, dynamic>> _combinations = [];

  Future<List<Map<String, dynamic>>> loadCombinations() async {
    // Dosyayı bulur, çeriğini okur ve JSON formatında ayrıştırır.
    // Ardından, kombinleri liste olarak döner.

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Expanded(
          child: ListView.builder( // Kombinleri listelemek için ListView kullanılır.
            itemCount: _combinations.length,
            itemBuilder: (context, index) {
              final kombin = _combinations[index];
              return _frostedCard( // Kombin kartı için buzlu buğulu bir efekti olan oluşturulur. Metodu aşağıda tanımlandı.
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
    ); 
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
    // Kombin kartı için buzlu buğulu bir efekt oluşturur.
    // Kartın üzerine tıklandığında onTap fonksiyonunu çağırır.
    // Kartın içeriği, verilen metni gösterir. O da kombin ismi olarak girilir.
    return GestureDetector( // Tıklanabilir
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
          color: Colors.black.withOpacity(.4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
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

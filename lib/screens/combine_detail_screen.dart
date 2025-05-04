import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CombineDetailScreen extends StatelessWidget {
  final Map<String, dynamic> combination;

  const CombineDetailScreen({super.key, required this.combination});

  Future<void> _deleteCombination(BuildContext context) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/combines.json');

    if (await file.exists()) {
      final data = await file.readAsString();
      final List<Map<String, dynamic>> existing =
          List<Map<String, dynamic>>.from(jsonDecode(data));

      final updated = existing
          .where((element) => element['name'] != combination['name'])
          .toList();

      await file.writeAsString(jsonEncode(updated));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kombin silindi.")),
      );

      Navigator.pop(context);
    }
  }

  Future<Map<String, String>> _getClothingPaths() async {
    final dir = await getApplicationDocumentsDirectory();
    final clothesFile = File('${dir.path}/clothes.json');

    Map<String, String> paths = {};

    if (await clothesFile.exists()) {
      final data = await clothesFile.readAsString();
      final clothes = List<Map<String, dynamic>>.from(jsonDecode(data));

      for (var category in [
        'Baş',
        'Üst',
        'DışGiyim',
        'Alt',
        'Çanta',
        'Ayakkabı'
      ]) {
        final name = combination[category];
        final match = clothes.firstWhere((item) => item['name'] == name,
            orElse: () => {});
        if (match.isNotEmpty && match['path'] != null) {
          paths[category] = match['path'];
        }
      }
    }

    return paths;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(combination['name'] ?? 'Kombin Detayı')),
      body: FutureBuilder<Map<String, String>>(
        future: _getClothingPaths(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final paths = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // 💡 Ortalama
              children: [
                for (var category in [
                  'Baş',
                  'Üst',
                  'DışGiyim',
                  'Alt',
                  'Çanta',
                  'Ayakkabı'
                ])
                  if (paths[category] != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: Container(
                              width: 90,
                              height: 130,
                              decoration: BoxDecoration(
                                border: Border.all(),
                                color: Colors.grey[200],
                              ),
                              child: Image.file(
                                File(paths[category]!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteCombination(context),
                    icon: const Icon(Icons.delete),
                    label: const Text("Kombini Sil"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

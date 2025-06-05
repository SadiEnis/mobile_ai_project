import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_ai_project/appbar_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// Bu ekran, kullanıcıların kaydettikleri kombinlerin detaylarını görüntülemesine ve silmesine olanak tanır.

class CombineDetailScreen extends StatelessWidget {
  final Map<String, dynamic> combination;

  const CombineDetailScreen({super.key, required this.combination});

  Future<void> _deleteCombination(BuildContext context) async {
    // Kombini silmek için uygulama belgeleri dizininden 'combines.json' dosyasını bulur.
    // İçeriğini okur ve JSON formatında ayrıştırır.(decode)
    // Ardından, silinecek kombin ismine göre filtreleme yapar ve güncellenmiş listeyi dosyaya yazar.

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/combines.json');

    if (await file.exists()) {
      final data = await file.readAsString();
      final List<Map<String, dynamic>> existing =
          List<Map<String, dynamic>>.from(jsonDecode(data));

      final updated = existing // Filtreleme işlemi. Dosyadaki data içerisinden ilgili kombini filtreler.
          .where((element) => element['name'] != combination['name'])
          .toList();

      await file.writeAsString(jsonEncode(updated)); // Güncellenmiş listeyi dosyaya yazar. İçinden bir kombin silinmiş olur.

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kombin silindi.")),
      );

      Navigator.pop(context); // Kombin detay ekranından geri döner.
    }
  }

  Future<Map<String, String>> _getClothingPaths() async {
    // Kombin detay ekranında gösterilecek kıyafetlerin dosya yollarını alır.
    // Ardından, kombin içindeki her bir kategori için kıyafet ismini bulur ve dosya yolunu alır.

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
        final name = combination[category]; // Kombin içindeki kategoriye ait kıyafet ismini alır. 
        final match = clothes.firstWhere((item) => item['name'] == name, // Kıyafet ismine göre eşleşen ilk öğeyi bulur.
            orElse: () => {}); // Eğer eşleşme bulunamazsa boş bir harita döner.
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
      appBar: AppBar(
        title: Text(combination['name'] ?? 'Kombin Detayı'), // Kombin ismini başlık olarak gösterir.
        backgroundColor: context.watch<AppBarThemeProvider>().appBarColor,
      ),
      body: FutureBuilder<Map<String, String>>(
        // Kombin detay ekranında kıyafetlerin dosya yollarını almak için FutureBuilder kullanılır.
        // Bu, asenkron bir işlem olduğu için FutureBuilder ile beklenir. Çünkü dosya okuma işlemi zaman alabilir.
        future: _getClothingPaths(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final paths = snapshot.data!;
          return SingleChildScrollView( // Ekran içeriği kaydırılabilir hale getirilir. Bu sayede ekran içeriği uzun olduğunda kullanıcı kaydırabilir.
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
                              decoration: BoxDecoration( // Kıyafet resimlerinin kutu görünümü için dekorasyon ayarları.
                                border: Border.all(),
                                color: Colors.grey[200],
                              ),
                              child: Image.file(
                                File(paths[category]!), // Kıyafet resim dosyasını alır ve gösterir.
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon( // Kombini silmek için buton
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

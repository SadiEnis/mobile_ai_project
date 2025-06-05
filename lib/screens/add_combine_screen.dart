import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../appbar_provider.dart';

// Bu ekran, kullanıcıların yeni kombinler eklemesine olanak tanır.
// Kullanıcı, kombin için bir isim girer ve ardından her bir kıyafet kategorisi için seçim yapar.
// Seçilen kıyafetler, cihazın depolama alanında JSON formatında kaydedilir.

class AddCombineScreen extends StatefulWidget {
  const AddCombineScreen({super.key});

  @override
  State<AddCombineScreen> createState() => _AddCombineScreenState();
}

class _AddCombineScreenState extends State<AddCombineScreen> {
  List<Map<String, dynamic>> _clothes = [];
  final Map<String, int> _indices = {
    'Baş': 0,
    'Üst': 0,
    'DışGiyim': 0,
    'Alt': 0,
    'Çanta': 0,
    'Ayakkabı': 0,
  }; // Kıyafet kategorileri için başlangıç indeksleri
  final Map<String, Map<String, dynamic>?> _selected = {
    'Baş': null,
    'Üst': null,
    'DışGiyim': null,
    'Alt': null,
    'Çanta': null,
    'Ayakkabı': null,
  }; // Seçilen kıyafetler için başlangıç değerleri

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() { // Ekran ilk yüklendiğinde çalışır.
    super.initState();
    _loadClothes();
  }

  Future<void> _loadClothes() async {
    // Uygulama belgeleri dizininden kıyafet verilerini yükler.
    // Eğer dosya mevcutsa, içeriğini okur ve JSON formatında ayrıştırır.
    // Ardından, _clothes listesine atar ve durumu günceller.

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/clothes.json');
    if (await file.exists()) {
      final data = await file.readAsString();
      final decoded = List<Map<String, dynamic>>.from(jsonDecode(data));
      setState(() {
        _clothes = decoded;
      });
    }
  }

  List<Map<String, dynamic>> _filteredClothes(String type) {
    // Kıyafet listesini kategoriye göre filtreler.
    // Belirtilen kategoriye ait kıyafetleri döndürür.

    return _clothes.where((item) => item['category'] == type).toList();
  }

  Widget _buildClothSelector(String title) {
    // Belirtilen kategori için kıyafet seçici widget'ı oluşturur.
    // Kategoriye ait kıyafetleri filtreler, mevcut indeksi ve seçilen kıyafeti alır.
    // Kullanıcı, sol ve sağ ok butonları ile kıyafetler arasında geçiş yapabilir.
    // Seçilen kıyafeti kaldırmak için çarpı butonu da bulunur.

    var filtered = _filteredClothes(title);
    if (title == "DışGiyim") {
      filtered = _filteredClothes("Üst"); // Dış giyim için üst kategorisinden filtreleme yapar. Dış giyim, üst kategorisinden seçilir.
    } else {
      filtered = _filteredClothes(title); // Diğer kategoriler için kendi kategorisinden filtreleme yapar.
    }
    final currentIndex = _indices[title]!;
    final selected = _selected[title]; // Seçilen kıyafet

    return Column(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row( // Yan yana üç satır bulunur: Sol ok, fotoğraf ve sağ ok-çarpı butonları.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton( // Sol ok butonu
              icon: const Icon(Icons.arrow_left),
              onPressed: (filtered.isEmpty || selected == null)
                  ? null
                  : () {
                      setState(() {
                        _indices[title] = (currentIndex - 1 + filtered.length) %
                            filtered.length;
                        _selected[title] =
                            filtered[_indices[title]! % filtered.length];
                      });
                    },
            ),
            Container( // Kıyafet fotoğrafları
              width: 80,
              height: 110,
              decoration: BoxDecoration(
                border: Border.all(),
                color: Colors.grey[200],
              ),
              child: selected != null
                  ? Image.file(File(selected['path']), fit: BoxFit.cover)
                  : const Center(
                      child: Text(
                        'Boş',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
            ),
            Column( // Sağ ok ve çarpı butonları
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: (filtered.isEmpty)
                      ? null
                      : () {
                          setState(() {
                            _indices[title] =
                                (currentIndex + 1) % filtered.length;
                            _selected[title] =
                                filtered[_indices[title]! % filtered.length];
                          });
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _selected[title] = null; // seçimi kaldır
                    });
                  },
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _saveCombination() async {
    // Kombin kaydetme işlemi yapar.
    // Kullanıcıdan kombin ismi alır, eğer boşsa uyarı gösterir.
    // Uygulama belgeleri dizininde "combines.json" dosyasına kaydeder.
    
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen kombin için bir isim girin.")),
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/combines.json');

    List<Map<String, dynamic>> existing = []; // Mevcut kombinleri tutar.
    if (await file.exists()) {
      final data = await file.readAsString();
      if (data.trim().isNotEmpty) {
        existing = List<Map<String, dynamic>>.from(jsonDecode(data));
        // Aynı isim kontrolü
        if (existing.any((element) => element['name'] == name)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bu isimde bir kombin zaten var.")),
          );
          return;
        }
      }
    }

    // Yeni kombin verisini oluşturur.
    final Map<String, dynamic> combination = {
      'name': name,
      'Baş': _selected['Baş']?['name'],
      'Üst': _selected['Üst']?['name'],
      'DışGiyim': _selected['DışGiyim']?['name'],
      'Alt': _selected['Alt']?['name'],
      'Çanta': _selected['Çanta']?['name'],
      'Ayakkabı': _selected['Ayakkabı']?['name'],
    };

    existing.add(combination);
    await file.writeAsString(jsonEncode(existing)); // Kombin Dart nesnesini JSON formatında dosyaya kaydeder.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Kombin kaydedildi!")),
    );

    _nameController.clear(); // input temizle
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kombin Ekle'),
        backgroundColor: context.watch<AppBarThemeProvider>().appBarColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Kombin İsmi',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Kıyafet kategorileri için seçim widget'ları oluşturulur. Sayfa tasarımı üstte Baş ortada Üst ve Dış onların altında Alt ve Çanta en altta Ayakkabı bulunacak şekilde yapıldı.
            _buildClothSelector('Baş'),
            Row(
              children: [
                Expanded(child: _buildClothSelector('Üst')),
                Expanded(child: _buildClothSelector('DışGiyim')),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildClothSelector('Alt')),
                Expanded(child: _buildClothSelector('Çanta')),
              ],
            ),
            _buildClothSelector('Ayakkabı'),
            const SizedBox(height: 16),
            
            SizedBox(
              width: 200,
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  await _saveCombination();
                  Navigator.pop(context, true); // Kombin kaydedildikten sonra geri döner.
                },
                child: const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

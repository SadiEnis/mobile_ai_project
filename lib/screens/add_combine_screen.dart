import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
  };
  final Map<String, Map<String, dynamic>?> _selected = {
    'Baş': null,
    'Üst': null,
    'DışGiyim': null,
    'Alt': null,
    'Çanta': null,
    'Ayakkabı': null,
  };

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClothes();
  }

  Future<void> _loadClothes() async {
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
    return _clothes.where((item) => item['category'] == type).toList();
  }

  Widget _buildClothSelector(String title) {
    final filtered = _filteredClothes(title);
    final currentIndex = _indices[title]!;
    final selected =
        filtered.isEmpty ? null : filtered[currentIndex % filtered.length];
    _selected[title] = selected;

    return Column(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left),
              onPressed: filtered.isEmpty
                  ? null
                  : () {
                      setState(() {
                        _indices[title] = (currentIndex - 1 + filtered.length) %
                            filtered.length;
                      });
                    },
            ),
            Container(
              width: 80,
              height: 110,
              decoration:
                  BoxDecoration(border: Border.all(), color: Colors.grey[200]),
              child: selected != null
                  ? Image.file(File(selected['path']), fit: BoxFit.cover)
                  : const Center(child: Text('Boş')),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: filtered.isEmpty
                      ? null
                      : () {
                          setState(() {
                            _indices[title] =
                                (currentIndex + 1) % filtered.length;
                          });
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _selected[title] = null;
                      _indices[title] = 0;
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
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen kombin için bir isim girin.")),
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/combines.json');

    List<Map<String, dynamic>> existing = [];
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

    // Kombin nesnesi
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
    await file.writeAsString(jsonEncode(existing));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Kombin kaydedildi!")),
    );

    _nameController.clear(); // input temizle
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kombin Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Kombin İsmi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
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
            ElevatedButton(
              onPressed: () async {
                await _saveCombination();
                Navigator.pop(context, true); // 👈 Ana sayfaya 'true' ile dön
              },
              child: const Text('Kaydet'),
            )
          ],
        ),
      ),
    );
  }
}

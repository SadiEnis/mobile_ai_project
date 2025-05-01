import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_ai_project/screens/add_clothes_screen.dart';
import 'package:path_provider/path_provider.dart';

class ClothesScreen extends StatefulWidget {
  const ClothesScreen({super.key});

  @override
  State<ClothesScreen> createState() => _MyClothesScreenState();
}

class _MyClothesScreenState extends State<ClothesScreen> {
  List<Map<String, dynamic>> _clothes = [];

  @override
  void initState() {
    super.initState();
    _loadClothes();
  }

  Future<void> _loadClothes() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/clothes.json';
    final file = File(path);
    if (await file.exists()) {
      final contents = await file.readAsString();
      if (contents.trim().isNotEmpty) {
        setState(() {
          _clothes = List<Map<String, dynamic>>.from(jsonDecode(contents));
        });
      }
    }
  }

  void _openDetailsModal(Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name']);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(item['path']), fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: item['category']),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Kıyafet İsmi',
                border: OutlineInputBorder(),
              ),
              controller: nameController,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _deleteClothes(item);
                    },
                    child: const Text('Sil'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _updateClothes(item, nameController.text);
                    },
                    child: const Text('Kaydet'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteClothes(Map<String, dynamic> item) async {
    _clothes.removeWhere((element) => element['name'] == item['name']);
    await _saveClothes();
  }

  Future<void> _updateClothes(
      Map<String, dynamic> oldItem, String newName) async {
    final index =
        _clothes.indexWhere((item) => item['name'] == oldItem['name']);
    if (index != -1) {
      _clothes[index]['name'] = newName.trim();
      await _saveClothes();
    }
  }

  Future<void> _saveClothes() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/clothes.json';
    final file = File(path);
    await file.writeAsString(jsonEncode(_clothes));
    setState(() {}); // UI güncellemesi için yeni durumu getiriyoruz.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kıyafetlerim')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          itemCount: _clothes.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 3 / 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            if (index == 0) {
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddClothesScreen()),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Icon(Icons.add, size: 40)),
                ),
              );
            }
            final item = _clothes[index - 1];
            return GestureDetector(
              onTap: () => _openDetailsModal(item),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(item['path']),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

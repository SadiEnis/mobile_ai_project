import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../appbar_provider.dart';

class AddClothesScreen extends StatefulWidget {
  const AddClothesScreen({super.key});

  @override
  State<AddClothesScreen> createState() => _AddClothesScreenState();
}

class _AddClothesScreenState extends State<AddClothesScreen> {
  File? _selectedImage;
  final TextEditingController _nameController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = ['Baş', 'Üst', 'Alt', 'Çanta', 'Ayakkabı'];

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kıyafet Ekle'),
        backgroundColor: context.watch<AppBarThemeProvider>().appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showImageSourceModal,
                  child: Container(
                    height: 400,
                    width: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _selectedImage == null
                        ? const Center(child: Icon(Icons.add, size: 50))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                Image.file(_selectedImage!, fit: BoxFit.cover),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 300,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Kıyafet İsmi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 300,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Kıyafet Türü',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCategory,
                    items: _categories
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 150,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _saveClothes,
                    child: const Text('Kaydet'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kameradan Çek'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveClothes() async {
    final name = _nameController.text.trim();

    if (_selectedImage == null || name.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tüm alanları doldurun ve fotoğraf ekleyin')),
      );
      return;
    }

    final clothes = await _loadExistingClothes();
    final nameExists = clothes.any((item) => item['name'] == name);
    if (nameExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bu isim zaten var. Lütfen başka bir isim girin.')),
      );
      return;
    }

    final newClothes = {
      'path': _selectedImage!.path,
      'name': name,
      'category': _selectedCategory,
    };

    clothes.add(newClothes);
    final path = await _getClothesFilePath();
    final file = File(path);
    await file.writeAsString(jsonEncode(clothes));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kıyafet kaydedildi!')),
    );

    setState(() {
      _selectedImage = null;
      _nameController.clear();
      _selectedCategory = null;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _getClothesFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/clothes.json';
  }

  Future<List<Map<String, dynamic>>> _loadExistingClothes() async {
    final path = await _getClothesFilePath();
    final file = File(path);
    if (await file.exists()) {
      final contents = await file.readAsString();
      if (contents.trim().isEmpty) return [];
      return List<Map<String, dynamic>>.from(jsonDecode(contents));
    } else {
      return [];
    }
  }
}

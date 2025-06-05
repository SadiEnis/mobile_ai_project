import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_ai_project/screens/add_clothes_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../appbar_provider.dart';

// Bu ekran, kullanıcıların kıyafetlerini görüntülemesine ve düzenlemesine olanak tanır.
// Kullanıcı, kıyafetleri görüntüleyebilir, ekleyebilir, düzenleyebilir ve silebilir.

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
    // Uygulama belgeleri dizininden kıyafet verilerini yükler.
    // Eğer dosya mevcutsa, içeriğini okur ve JSON formatında ayrıştırır.
    // Ardından, _clothes listesine atar ve durumu günceller.
    
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
    // Kıyafet detaylarını gösteren modal alt sayfasını açar.
    // Kullanıcı, kıyafet ismini düzenleyebilir ve kıyafeti silebilir.

    final nameController = TextEditingController(text: item['name']);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ClipRRect( // Kıyafet resmini gösterir.
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(item['path']), fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            TextField( // Kıyafet kategorisini gösterir, düzenlenemez.
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: item['category']),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextField( // Kıyafet ismini düzenlemek için kullanılır.
              decoration: const InputDecoration(
                labelText: 'Kıyafet İsmi',
                border: OutlineInputBorder(),
              ),
              controller: nameController,
            ),
            const SizedBox(height: 16),
            Row( // Silme ve kaydetme butonlarını içerir.
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
    // Kıyafeti siler ve dosyadan günceller.
    // Kıyafet ismine göre _clothes listesinden siler ve dosyayı günceller.
    // Metod Future'dur çünkü asenkron işlemler içerir.

    _clothes.removeWhere((element) => element['name'] == item['name']);
    await _saveClothes();
  }

  Future<void> _updateClothes(
    // Kıyafet ismini günceller.
    // Kullanıcı tarafından girilen yeni ismi alır ve _clothes listesindeki ilgili öğeyi günceller.

      Map<String, dynamic> oldItem, String newName) async {
    final index =
        _clothes.indexWhere((item) => item['name'] == oldItem['name']); // Eski kıyafet ismine göre indeksi bulur.
    if (index != -1) {
      _clothes[index]['name'] = newName.trim(); // trim metodu ile baştaki ve sondaki boşlukları kaldırır.
      await _saveClothes();
    }
  }

  Future<void> _saveClothes() async {
    // Kıyafet listesini uygulama belgeleri dizinine kaydeder.
    // Kıyafet verilerini JSON formatında kodlar ve "clothes.json" dosyasına yazar.
    
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/clothes.json';
    final file = File(path);
    await file.writeAsString(jsonEncode(_clothes));
    setState(() {}); // UI güncellemesi için yeni durumu getiriyoruz.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kıyafetlerim'),
        backgroundColor: context.watch<AppBarThemeProvider>().appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.builder( // Kıyafetleri ızgara düzeninde gösterir. 
          itemCount: _clothes.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( // ızgara düzeni için ayarlar.
            crossAxisCount: 3, // Her satırda 3 öğe gösterir.
            childAspectRatio: 3 / 4, // Her öğenin genişlik-yükseklik oranı 3:4
            crossAxisSpacing: 8, // Öğeler arasındaki yatay boşluk (px)
            mainAxisSpacing: 8, // Öğeler arasındaki dikey boşluk (px)
          ),
          itemBuilder: (context, index) { // Kıyafet öğelerini oluşturur.
            if (index == 0) {
              return GestureDetector( // İlk öğe, yeni kıyafet ekleme butonudur. Tıklanabilir içinde + butonu olan bir resim butondur.
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute( // Yeni kıyafet ekleme ekranına yönlendirir.
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
            return GestureDetector( // Kıyafet öğesine tıklanabilirlik ekler.
              onTap: () => _openDetailsModal(item),
              child: ClipRRect( // ClpRRect, köşeleri yuvarlatılmış bir resim gösterir.
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(item['path']),
                  fit: BoxFit.cover, // Resmi kapsayıcıya sığdırır.
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../appbar_provider.dart';

// Ekleme ekranı, kullanıcıların kıyafet eklemesine olanak tanır.
// Kullanıcılar fotoğraf çekebilir veya galeriden seçebilir, kıyafet ismi ve türü ekleyebilir.

// Widget yapısı, StatefulWidget olarak tanımlanmıştır çünkü kullanıcı etkileşimlerine bağlı olarak değişiklik gösterebilir.
class AddClothesScreen extends StatefulWidget {
  const AddClothesScreen({super.key});

  @override
  State<AddClothesScreen> createState() => _AddClothesScreenState();
}

class _AddClothesScreenState extends State<AddClothesScreen> {
  // Ekleme ekranı için gerekli değişkenler ve kontroller tanımlanır.
  // _selectedImage: Seçilen fotoğrafı tutar.
  // _nameController: Kıyafet ismini tutan metin kontrolü.
  // _selectedCategory: Seçilen kıyafet türünü tutar.
  // _categories: Kıyafet türlerini tutan liste.
  // _picker: Fotoğraf seçmek için ImagePicker kullanılır.

  File? _selectedImage;
  final TextEditingController _nameController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = ['Baş', 'Üst', 'Alt', 'Çanta', 'Ayakkabı']; // Uygulama için belirlediğimiz kıyafet türleri.
  // Üst türü hem ceketleri hem de tişörtleri hem de gömlekleri kapsar. Kullanıcı isterse tişört üzerine kazak ya da tişört üzerine ceket ekleyebilir.

  final ImagePicker _picker = ImagePicker(); // Kamera

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kıyafet Ekle'),
        backgroundColor: context.watch<AppBarThemeProvider>().appBarColor, // AppBar rengi, Provider'dan alınır. notifyListeners ile güncellenir. 
        // Detaylar için appbar_provider.dart dosyasına bakabilirsiniz.
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView( // Ekran kaydırılabilir hale getirilir, böylece klavye açıldığında alanlar kaybolmaz.
          child: Center(
            child: Column(
              children: [
                GestureDetector( // Kullanıcı fotoğraf eklemek için bu alana dokunabilir. Tıklanabilir image denilebilir kısacası.
                  onTap: _showImageSourceModal, // Fotoğraf kaynağı seçimi için modal gösterilir. Meotd aşağıda tanımlanmıştır.
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
                          ), // Seçilen fotoğraf gösterilir. Eğer fotoğraf seçilmemişse, artı ikonu gösterilir.
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 300, 
                  child: TextField( // Kıyafet ismi için metin alanı. Kullanıcı buraya ismi girebilir. Ancak bu isim benzersiz olmalıdır aksi takdirde hata mesajı gösterilir.
                    controller: _nameController,
                    decoration: const InputDecoration( 
                      labelText: 'Kıyafet İsmi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField<String>( // Kıyafet türü seçimi için dropdown menü. Kullanıcı buradan kıyafet türünü seçebilir.
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
                SizedBox(
                  width: 150,
                  height: 45,
                  child: ElevatedButton( // Kıyafet kaydetme butonu. Kullanıcı bu butona tıkladığında kıyafet kaydedilir.
                    onPressed: _saveClothes, // Kıyafet kaydetme işlemi için metod çağrılır. Metod aşağıda tanımlanmıştır.
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
    // Kullanıcı fotoğraf kaynağını seçmek için modal gösterilir.
    // Kullanıcıya kamera veya galeriden fotoğraf seçme seçenekleri sunulur.
    // Modal, SafeArea ile sarılır, böylece ekranın kenarlarına yapışmaz.
    // Wrap widget'ı kullanılarak modal içeriği sarılır, böylece ekranın altına yapışmaz.
    // ListTile widget'ları kullanılarak kamera ve galeri seçenekleri sunulur.
    // Kullanıcı bir seçeneğe tıkladığında, modal kapatılır ve ilgili fotoğraf kaynağı seçilir.
    // Seçilen fotoğraf kaynağına göre _pickImage metoduna yönlendirilir. Metod aşağıda tanımlanmıştır.

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea( // Ekranın kenarlarına yapışmaması içindir.
          child: Wrap( // Ekranın altına yapışmaması içindir.
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kameradan Çek'),
                onTap: () {
                  Navigator.of(context).pop(); // Modal kapatılır.
                  _pickImage(ImageSource.camera); // Kameradan fotoğraf çekilir.
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.of(context).pop(); // Modal kapatılır.
                  _pickImage(ImageSource.gallery); // Galeriden fotoğraf seçilir.
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveClothes() async {
    // Kullanıcı tarafından girilen kıyafet ismi, seçilen fotoğraf ve türü kaydeder.
    // Eğer tüm alanlar doldurulmamışsa veya fotoğraf seçilmemişse, kullanıcıya hata mesajı gösterilir.
    // Kıyafet ismi benzersiz olmalıdır, eğer aynı isimde bir kıyafet varsa kullanıcıya hata mesajı gösterilir.

    final name = _nameController.text.trim();

    if (_selectedImage == null || name.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tüm alanları doldurun ve fotoğraf ekleyin')),
      );
      return;
    } // Eğer fotoğraf seçilmemişse veya kıyafet ismi boşsa, kullanıcıya hata mesajı gösterilir. 
    // Her şey yolunda ise aşağıdaki işlemler yapılır.

    final clothes = await _loadExistingClothes(); // Mevcut kıyafetler yüklenir. Eğer dosya yoksa boş liste döner. Metod aşağıda tanımlanmıştır.
    final nameExists = clothes.any((item) => item['name'] == name); // Kıyafet ismi benzersiz olmalıdır. Eğer aynı isimde bir kıyafet varsa, nameExists TRUE OLUR.
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
    }; // Yeni kıyafet bilgileri oluşturulur. Seçilen fotoğrafın yolu, kıyafet ismi ve türü eklenir. Kıyafet JSON karakterinde tutulur.

    clothes.add(newClothes);
    final path = await _getClothesFilePath();
    final file = File(path);
    await file.writeAsString(jsonEncode(clothes));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kıyafet kaydedildi!')),
    );

    setState(() { // Ekleme ekranı temizlenir. State güncellenir.
      _selectedImage = null;
      _nameController.clear();
      _selectedCategory = null;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    // Kullanıcıdan fotoğraf seçmek için ImagePicker kullanılır.
    // Kullanıcı kamera veya galeriden fotoğraf seçebilir.
    // Seçilen fotoğrafın yolu alınır ve _selectedImage değişkenine atanır.

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _getClothesFilePath() async {
    // Uygulama belgeleri dizininden kıyafetler için bir dosya yolu alır.
    // Bu dosya, kıyafet bilgilerini JSON formatında saklamak için kullanılır.
    // path_provider paketinden getApplicationDocumentsDirectory kullanılır.
    // Bu metod, cihazın uygulama belgeleri dizinini bulur ve kıyafetler için bir dosya yolu oluşturur.

    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/clothes.json';
  }

  Future<List<Map<String, dynamic>>> _loadExistingClothes() async {
    // Mevcut kıyafetleri yükler. Eğer dosya yoksa boş liste döner.
    // Kıyafetler, JSON formatında saklanır ve bu metod, dosyadan kıyafetleri okur.
    // Eğer dosya mevcut değilse veya içeriği boşsa, boş liste döner.

    final path = await _getClothesFilePath(); // Kıyafet dosyasının yolu alınır.
    final file = File(path);
    if (await file.exists()) {
      final contents = await file.readAsString();
      if (contents.trim().isEmpty) return [];
      return List<Map<String, dynamic>>.from(jsonDecode(contents)); // Dosya içeriği okunur ve JSON formatında haritalara dönüştürülür. JSONdecode, JSON karakter dizisini Dart nesnelerine dönüştürür.
    } else {
      return [];
    }
  }
}

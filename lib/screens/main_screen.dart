import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_ai_project/screens/add_clothes_screen.dart';
import 'package:mobile_ai_project/screens/clothes_screen.dart';
import 'package:path_provider/path_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isLoggedIn = false;
  String _username = '';
  String _gender = '';

  List<String> dummyCombinations = [
    "Kombin 1",
    "Kombin 2",
    "Kombin 3",
    "Kombin 4",
    "Kombin 5",
    "Kombin 6",
    "Kombin 7",
  ];

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Gardırobum'),
              backgroundColor: Colors.blue.shade400,
            ),
            // Drawer ekledik. Kullanıcı giriş yapmışsa görünmesini istedik ve kullanıcının yapabileceği işlemleri tek bir bardan görsün istedik.
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    // Kullanıcı bilgilerini göstermek için UserAccountsDrawerHeader kullandık. Kullanıcı adı ve cinsiyet bilgilerini gösteriyoruz.
                    accountName: Text(_username),
                    accountEmail: Text('Cinsiyet: $_gender'),
                    currentAccountPicture: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40),
                    ),
                    decoration: BoxDecoration(color: Colors.blue.shade300),
                  ),
                  // ListTile ile menü öğelerini oluşturuyoruz. Her bir öğe için ikon ve metin ekliyoruz.
                  // onTap ile her bir öğeye tıklandığında ne olacağını belirtiyoruz. pop ile drawer'ı kapatıyoruz. pop fonksiyonu mevcut sayfayı kapatır.
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Ana Sayfa'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Kıyafet Ekle'),
                    onTap: () {
                      // Kıyafet ekle sayfasına yönlendirme
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddClothesScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.checkroom),
                    title: const Text('Kıyafetlerim'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ClothesScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_box),
                    title: const Text('Kombin Ekle'),
                    onTap: () {
                      // Kombin ekle sayfasına yönlendirme (sonra)
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.feedback),
                    title: const Text('Geri Bildirim'),
                    onTap: () {
                      // Geri bildirim sayfası (sonra)
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Hakkımızda'),
                    onTap: () {
                      // Hakkımızda sayfası (sonra)
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // Kıyafet ekle
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddClothesScreen()),
                );
              },
              child: const Icon(Icons.add),
            ),
            //
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Hoş geldin, $_username!',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: dummyCombinations.length,
                      itemBuilder: (context, index) {
                        final kombin = dummyCombinations[index];
                        // Kombinleri listelemek için ListView kullanıyoruz. Dummy kombin listesi yukarıda tanımlı.
                        // ListView.builder ile listeyi oluşturuyoruz. itemCount ile kaç tane olduğunu belirtiyoruz.
                        // itemBuilder ile de her bir elemanı oluşturuyoruz. Aşağıda tanımlı olan _frostedCard fonksiyonunu çağırıyoruz. Her bir kartın nasıl olacağını belirtiyoruz.
                        return _frostedCard(kombin);
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            body:
                _buildLoginPage()); // Giriş yapmamışsa cinsiyet seçme ekranı ve isim girme ekranı gelecek.
  }

  Widget _buildLoginPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Cinsiyet Seçin',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _genderButton('Kadın', Colors.pink),
              const SizedBox(width: 20),
              _genderButton('Erkek', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_data.txt');

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final parts = content.split(',');
        setState(() {
          _username = parts[0];
          _gender = parts[1];
          _isLoggedIn = true;
        });
      }
    }
  }

  Future<void> _saveUser(String name, String gender) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_data.txt');
    await file.writeAsString('$name,$gender');

    setState(() {
      _username = name;
      _gender = gender;
      _isLoggedIn = true;
    });
  }

  void _selectGender(String gender) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('İsmini Gir'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'İsmin'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveUser(nameController.text.trim(), gender);
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  Widget _genderButton(String gender, Color color) {
    return ElevatedButton(
      onPressed: () => _selectGender(gender),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        gender,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _frostedCard(String text) {
    return GestureDetector(
      onTap: () {
        // Kombin detayına yönlendirme (sonra yapılacak)
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        // margin kartların arasındaki boşluk, padding ise kartın içindeki boşluk.
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.1),
          // opacity ile arka plan rengini ayarlıyoruz. Opaklık ayarı yapıyoruz. Hafif buğulu gri bir görünümü olacak arka plan görünecek ama yazılar okunabilecek.
        ),
        child: ClipRRect(
          // Kartın daha yumuşak bir görünüm kazanması için widget olarak ClipRRect kullanıyoruz. (slaytta yok yine)
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            // Kartlara hafif gölge efekti vermek için kullandık. x ve y kordinatları için ayrı ayrı ayarlanabiliyor.
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              // Bu widget'tan aşağısı artık kartın içeriği oluyor.
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

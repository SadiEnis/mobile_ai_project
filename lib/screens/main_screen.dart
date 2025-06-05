import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_ai_project/appbar_provider.dart';
import 'package:mobile_ai_project/screens/settings_sreen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mobile_ai_project/screens/add_clothes_screen.dart';
import 'package:mobile_ai_project/screens/add_combine_screen.dart';
import 'package:mobile_ai_project/screens/clothes_screen.dart';
import 'package:mobile_ai_project/screens/combines_screen.dart';

// Bu ekran, uygulamanın ana ekranıdır. Kullanıcı giriş yapmamışsa cinsiyet seçme ve isim girme ekranı gösterilir.
// Kullanıcı giriş yapmışsa, ana sayfa, kıyafet ekleme, kıyafetlerim, kombin ekleme, kombinlerim gibi seçenekler sunulur.
// Kullanıcı, uygulama içinde gezinmek için bir drawer kullanabilir. Ayrıca, kullanıcı geri bildirim gönderebilir ve ayarları değiştirebilir.

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isLoggedIn = false;
  String _username = '';
  String _gender = '';

  Future<List<Map<String, dynamic>>> loadCombinations() async {
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
    return _isLoggedIn
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Dolabım Şahane'),
              backgroundColor: context.watch<AppBarThemeProvider>().appBarColor,
            ),
            // Drawer ekledik. Kullanıcı giriş yapmışsa görünmesini istedik ve kullanıcının yapabileceği işlemleri tek bir bardan görsün istedik.
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader( // Kullanıcı hesabı bilgilerini göstermek için UserAccountsDrawerHeader kullandık.
                    // UserAccountsDrawerHeader, Drawer içinde kullanıcı bilgilerini göstermek için kullanılır.
                    // Kullanıcı adı, cinsiyet ve profil resmi gibi bilgileri gösterir.
                    accountName: Text(_username,
                        style: const TextStyle(color: Colors.black)),
                    accountEmail: Text('Cinsiyet: $_gender',
                        style: const TextStyle(color: Colors.black)),
                    currentAccountPicture: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40),
                    ),
                    decoration: BoxDecoration(
                        color:
                            context.watch<AppBarThemeProvider>().appBarColor),
                  ),

                  // ListTile ile menü öğelerini oluşturuyoruz. Her bir öğe için ikon ve metin ekliyoruz.
                  // onTap ile her bir öğeye tıklandığında ne olacağını belirtiyoruz. pop ile drawer'ı kapatıyoruz. pop fonksiyonu mevcut sayfayı kapatır.
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Ana Sayfa'),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const MainScreen();
                      }));
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddCombineScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.class_),
                    title: const Text('Kombinlerim'),
                    onTap: () {
                      // Kombin ekle sayfasına yönlendirme (sonra)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CombinesScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.feedback),
                    title: const Text('Geri Bildirim'),
                    onTap: () async {
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: 'gucluersadienis@gmail.com',
                        query: 'subject=Geri Bildirim&body=Merhaba,',
                      );

                      if (await canLaunchUrl(emailUri)) {
                        await launchUrl(emailUri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Mail uygulaması açılamadı.")),
                        );
                      }

                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Ayarlar'),
                    onTap: () {
                      // Kombin ekle sayfasına yönlendirme (sonra)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsScreen()),
                      );
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
                  MaterialPageRoute( // FloatingActionButton'a tıklandığında AddClothesScreen'e yönlendirir.
                      builder: (context) => const AddClothesScreen()),
                );
              },
              child: const Icon(Icons.add),
            ),
            body: Padding( // Ana sayfa içeriği geçici bir sayfadır. Herhangi bir işlevliği bulunmamaktadır.
              // Farklı mevsimlere göre kreasyon önerileri sunar. Ayrıca bir ChatBot bölümü de eklenmiştir. Bunkar henüz işlevsel değildir.
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ChatBot",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  hintText: "Coming Soon...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text("Gönder"),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Kreasyon Önerileri",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _buildImageButton("lib/assets/spring.png", "İlkbahar"),
                        _buildImageButton("lib/assets/summer.jpg", "Yaz"),
                        _buildImageButton("lib/assets/fall.png", "Sonbahar"),
                        _buildImageButton("lib/assets/winter.png", "Kış"),
                      ],
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

  Widget _buildImageButton(String imagePath, String label) {
    return GestureDetector( // Bir resim butonu oluşturur.
      onTap: () {
        // Henüz tepki vermeyecek şekilde bırakıldı.
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPage() {
    // Giriş yapmamış kullanıcılar için cinsiyet seçme ve isim girme ekranı.

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
    // Uygulama başlatıldığında kullanıcı verilerini kontrol eder.
    // Eğer kullanıcı verileri varsa, kullanıcı adı ve cinsiyet bilgilerini alır.
    // Kullanıcı verileri yoksa, giriş yapmamış olarak kalır.
    // Kullanıcı verileri, uygulama belgeleri dizininde user_data.txt dosyasında saklanır.

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
    // Kullanıcı adı ve cinsiyet bilgilerini user_data.txt dosyasına kaydeder.
    // Kullanıcı giriş yaptıktan sonra bu metod çağrılır.

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
    // Cinsiyet seçildiğinde, kullanıcıdan ismini girmesini ister. Bir AlertDialog gösterir.
    // Kullanıcı ismini girdikten sonra, _saveUser metodunu çağırarak kullanıcı verilerini kaydeder.

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
    // Cinsiyet seçimi için buton oluşturur. Butona tıklandığında _selectGender metodunu çağırır.
    // Butonun rengi, cinsiyete göre değişir. Kadın için pembe, erkek için mavi kullanılır.
    
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
}

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
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
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final directory =
        await getApplicationDocumentsDirectory(); // Uygulama klasörünü alıyoruz.
    final file = File(
        '${directory.path}/user_data.txt'); // O klasör içindeki dosyamızı da alıyoruz. Aşağıda dosyamızı kullanacağz.

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final parts = content.split(',');

        // Eğer dosya içeriği boş değilse virgülden ayırıyoruz ve ilk elemanı isim, ikinci elemanı cinsiyet olarak alıyoruz.
        setState(() {
          _username = parts[0];
          _gender = parts[1];
          _isLoggedIn = true;
        });
        // Kullanıcı verilerini dosyadan okuyoruz ve eğer doluysa giriş yapıyoruz. Değilse giriş ekranı çıkıyor.
        // Uygulama geliştirilip bu kısımları login haline getirebiliriz ve gardırobu da bir API'den çekebiliriz.
      }
    }
  }

  Future<void> _saveUser(String name, String gender) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_data.txt');
    await file.writeAsString('$name,$gender');
    // Kullanıcı verilerini dosyaya kaydediyoruz. Üstteki _checkUser() fonksiyonu

    setState(() {
      _username = name;
      _gender = gender;
      _isLoggedIn = true;
    });
  }

  void _selectGender(String gender) {
    final nameController = TextEditingController();
    // Kullanıcadan isim almak için oluşturuyoruz.

    showDialog(
      // Kullanıcıdan isim almak için cinsiyet seçimi ardından bir dialog popup kullanıyoruz.
      context: context,
      builder: (context) {
        return AlertDialog(
          // Dialog popup açıyoruz.
          title: const Text('İsmini Gir'),
          content: TextField(
            controller: nameController,
            // Kullanıcıdan isim almak için bir textfield açıyoruz.
            decoration: const InputDecoration(hintText: 'İsmin'),
          ),
          actions: [
            // Diyalogdaki buton
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // pop Navigator için kapatmak için kullanılan bir fonksiyondur.
                // Kullanıcıdan aldığımız isim ve cinsiyeti dosyaya kaydediyoruz.
                _saveUser(nameController.text.trim(), gender);
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoggedIn ? _buildHomePage() : _buildLoginPage(),
      // Kullanıcı giriş yapmışsa ana sayfayı, yapmamışsa giriş sayfasını gösteriyoruz. Üçlü operatör ile kontrol ediyoruz.
      // İkisi de aşağıda tanımlı widget dönderen fonksiyonlar.
      floatingActionButton: _isLoggedIn
          ? FloatingActionButton(
              onPressed: () {
                // Kıyafet ekle butonu (sonra yapılacak)
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
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
              // Butonları aşağıdaki oluşturuyoruz. Uzun uzun yazmaktansa bir fonksiyon oluşturup çağırıyoruz. Rengi ve text'i parametre olarak alıyor.
            ],
          ),
        ],
      ),
    );
  }

  Widget _genderButton(String gender, Color color) {
    return ElevatedButton(
      onPressed: () => _selectGender(gender),
      // Yukarıda fonksiyon tanımlı ve cinsiyet seçimi yapıldığında çağırıyoruz.
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

  Widget _buildHomePage() {
    return SafeArea(
      // Ekranın üst kısmındaki çentiklere göre ekranı ayarlıyor. Bu epey detay bir şey instagramda dolaşırken karşıma çıktı neden olmasın dedim.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Hoş geldin, $_username!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: dummyCombinations.length,
                itemBuilder: (context, index) {
                  final kombin = dummyCombinations[index];
                  return _frostedCard(kombin);
                },
                // Kombinleri listelemek için ListView kullanıyoruz. Dummy kombin listesi yukarıda tanımlı.
                // ListView.builder ile listeyi oluşturuyoruz. itemCount ile kaç tane olduğunu belirtiyoruz.
                // itemBuilder ile de her bir elemanı oluşturuyoruz. Aşağıda tanımlı olan _frostedCard fonksiyonunu çağırıyoruz. Her bir kartın nasıl olacağını belirtiyoruz.
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _frostedCard(String text) {
    return GestureDetector(
      onTap: () {
        // Kombin detay sayfasına iletecek (sonra yapılacak)
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        // margin kartların arasındaki boşluk, padding ise kartın içindeki boşluk.
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(.1),
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

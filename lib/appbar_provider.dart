import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AppBarThemeProvider extends ChangeNotifier {
  static final Map<String, Color> colorOptions = {
    'Mavi': Colors.blue,
    'Kırmızı': Colors.red,
    'Yeşil': Colors.green,
    'Mor': Colors.purple,
    'Pembe': Colors.pink,
    'Sarı': Colors.yellow,
    'Turkuaz': Colors.tealAccent,
  };

  late Color _appBarColor;
  late String _selectedColorName;
  bool _isDarkMode = false;
  bool _isInitialized = false;
  // Uygulama başlatıldığında ayarların yüklendiğini kontrol etmek için kullanılır.

  Color get appBarColor => _appBarColor;
  String get selectedColorName => _selectedColorName;
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  // Sayfanın koyu mu açık mı olacağnı ThemeMode ile ayarlıyoruz.
  // Koyu mod açık ise ThemeMode.dark, değilse ThemeMode.light döner.

  AppBarThemeProvider() {
    _selectedColorName = 'Mavi'; // varsayılan
    _appBarColor = colorOptions[_selectedColorName]!;
    _loadSettingsFromFile();

    // Uygulama başlatıldığında ayarları dosyadan yükler.
  }

  Future<void> setColorByName(String name) async {
    _selectedColorName = name;
    _appBarColor = colorOptions[name]!;
    notifyListeners();
    await _saveSettingsToFile();

    // Renk değiştiğinde çağrılır.
    // Kullanıcı arayüzünü günceller.
    // notifyListeners() ile diğer sayfalara iletilir.
  }

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
    _saveSettingsToFile();

    // Koyu mod açık/kapalı durumu değiştiğinde çağrılır.
    // Kullanıcı arayüzünü günceller.
    // notifyListeners() ile diğer sayfalara iletilir.
  }

  Future<void> _saveSettingsToFile() async {
    try {
      final file = await _getSettingsFile();
      final data =
          '$_selectedColorName|${_appBarColor.value.toRadixString(16)}|${_isDarkMode ? "1" : "0"}';
      await file.writeAsString(data);
    } catch (e) {
      print('HATA: Ayarlar kaydedilemedi: $e');
    }
    // Ayarları dosyaya kaydeder.
    // Renk adı, renk değeri ve koyu mod durumu ile birlikte.
    // Her birini ayırmak için '|' karakteri kullanılır.
  }

  Future<void> _loadSettingsFromFile() async {
    // Dosyadan ayarları yükler.
    try {
      final file = await _getSettingsFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final parts = content.split('|');
        if (parts.length == 3) {
          final name = parts[0];
          final colorValue = int.parse(parts[1], radix: 16);
          final darkMode = parts[2] == "1";

          _selectedColorName = name;
          _appBarColor = Color(colorValue);
          _isDarkMode = darkMode;
        }
      }
    } catch (e) {
      print('HATA: Ayarlar okunamadı: $e');
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<File> _getSettingsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/settings.txt');
    // Ayarları saklamak için kullanılacak dosya yolu
    // Uygulama belgeleri dizininde "settings.txt" adında bir dosya oluşturur.
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import '../appbar_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? _profileImage;
  String _name = 'Ad Soyad';
  String _gender = 'Belirtilmedi';
  bool _isDarkMode = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename("profile.jpg"); // örneğin image.jpg
      final savedImage =
          await File(picked.path).copy('${appDir.path}/$fileName');

      setState(() {
        _profileImage = savedImage;
      });

      // Gerekirse dosya yolu SharedPreferences veya bir dosya içinde saklanabilir
    }
  }

  Future<void> _loadUser() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_data.txt');

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final parts = content.split(',');
        setState(() {
          _name = parts[0];
          _gender = parts[1];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppBarThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: provider.appBarColor,
      ),
      body: !provider.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: Icon(Icons.person, size: 40)),
                ),
                const SizedBox(height: 16),

                Center(
                    child: Text(_name, style: const TextStyle(fontSize: 18))),

                Center(
                    child: Text(_gender,
                        style: const TextStyle(color: Colors.grey))),

                const Divider(height: 32),

                const Text('Uygulama Ayarları',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(height: 8),

                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('AppBar Rengini Değiştir'),
                  trailing: DropdownButton<String>(
                    value: provider.selectedColorName,
                    items: AppBarThemeProvider.colorOptions.entries
                        .map((entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(
                                entry.key,
                                style: TextStyle(color: entry.value),
                              ),
                            ))
                        .toList(),
                    onChanged: (String? name) {
                      if (name != null) {
                        provider.setColorByName(name);
                      }
                    },
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Tema (Açık/Koyu)'),
                  trailing: GestureDetector(
                    onTap: () {
                      provider.toggleTheme(!provider.isDarkMode);
                    },
                    child: Container(
                      width: 64,
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: provider.isDarkMode
                            ? Colors.deepPurpleAccent
                            : Colors.grey.shade300,
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            // Animasyon için kullanılıyor. Soldan sağa sağdan sola
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            left: provider.isDarkMode ? 30 : 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  provider.isDarkMode
                                      ? Icons
                                          .nightlight_round // Ay ikonu (sağda)
                                      : Icons.wb_sunny, // Güneş ikonu (solda)
                                  color: provider.isDarkMode
                                      ? Colors.deepPurpleAccent
                                      : Colors.amber,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // SwitchListTile(
                //   secondary: const Icon(Icons.brightness_6),
                //   title: const Text('Tema (Açık/Koyu)'),
                //   value: provider.isDarkMode,
                //   onChanged: (val) {
                //     provider.toggleTheme(val);
                //   },
                // ),

                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Uygulamayı Paylaş'),
                  onTap: () {
                    // paylaşım kodu
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Gizlilik Politikası'),
                  onTap: () {
                    // gizlilik politikası
                  },
                ),
              ],
            ),
    );
  }
}

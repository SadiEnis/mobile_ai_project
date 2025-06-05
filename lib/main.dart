import 'package:flutter/material.dart';
import 'package:mobile_ai_project/appbar_provider.dart';
import 'package:provider/provider.dart';

import 'screens/main_screen.dart';

// Bu uygulama, kullanıcıların açık ve koyu tema arasında geçiş yapabilmesini sağlar.
// Ayrıca, kullanıcılar uygulamanın AppBar rengini değiştirebilirler.
// Uygulama, Provider kullanarak durum yönetimini gerçekleştirir.
// main.dart dosyası, uygulamanın başlangıç noktasıdır.
// Uygulama, MaterialApp widget'ı ile başlar ve tema ayarlarını içerir.
// Kullanıcı arayüzü, MainScreen widget'ı ile oluşturulur.

// Ayrıca APP_DOCS\android\app\src\main\AndroidManifest.xml içinde yer alan bir takım izinler var. 
// Uygulama cihazın kamerasını ve depolama alanını kullanabilmek için bu izinlere ihtiyaç duyar. Bu izinler o dosyada tanımlanmıştır. (E-Mail üzerinden gönderildi.)
   
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppBarThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppBarThemeProvider>(context);

    if (!provider.isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Debug banner'ı gizler.

      themeMode: provider.themeMode,
      // açık/koyu mod seçimi buradan yapılır. Provider'dan alınır.

      theme: ThemeData(
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: provider.appBarColor,
          // AppBar rengi burada ayarlanır. Provider'dan alınır
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      // Açık tema için ayarlanır.

      // Koyu tema için ayarlar.
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: provider.appBarColor,
        ),
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

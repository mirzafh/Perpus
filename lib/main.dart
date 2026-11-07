import 'package:flutter/material.dart';
import 'package:perpus/pages/Login.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBhhi2fTAHh-aTDNVg6Zn_ZjdXZ0hsLHuM",
      authDomain: "pathama-d3463.firebaseapp.com",
      projectId: "pathama-d3463",
      storageBucket: "pathama-d3463.firebasestorage.app",
      messagingSenderId: "1086347041751",
      appId: "1:1086347041751:web:42caa377cc30db57b64992",
    ),
  );
  runApp(const Pathama());
}

class Warna {
  static const lightBg = Color(0xFFF8FAF6);
  static const lightBoxPrimary = Color(0xFFFFFFFF);
  static const lightBoxSecondary = Color(0xFFEDF5E8);
  static const lightBorder = Color(0xFFE1EBD9);
  static const lightPrimary = Color(0xFF70B251);
  static const lightMid = Color(0xFF8DC970);
  static const lightHighlight = Color(0xFFA3E635);
  static const lightTextPrimary = Color(0xFF1C251B);
  static const lightTextSecondary = Color(0xFF5F6C5D);
  static const lightGradient = LinearGradient(
    colors: [lightPrimary, lightHighlight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const lightGradientLogin = LinearGradient(
    colors: [lightPrimary, lightHighlight],
    begin: AlignmentGeometry.topCenter,
    end: Alignment.bottomCenter,
  );
  static const lightGreenDiagonal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightHighlight, lightMid, lightPrimary],
    stops: [0.0, 0.45, 1.0],
  );
  static const lightGreenRadialGlow = RadialGradient(
    center: Alignment(-1.0, -1.0),
    radius: 1.5,
    colors: [lightMid, lightPrimary, lightHighlight],
    stops: [0.0, 0.4, 1.0],
  );

  static const darkBg = Color(0xFF131A12);
  static const darkBoxPrimary = Color(0xFF1D261F);
  static const darkBoxSecondary = Color(0xFF27332A);
  static const darkBorder = Color(0xFF334337);
  static const darkPrimary = Color(0xFF72A855);
  static const darkMid = Color(0xFF38512C);
  static const darkAccent = Color(0xFF537C3E);
  static const darkTextPrimary = Color(0xFFEBF2EA);
  static const darkTextSecondary = Color(0xFF93A392);
  static const darkGradient = LinearGradient(
    colors: [darkPrimary, darkMid],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const darkGradientLogin = LinearGradient(
    colors: [darkMid, darkBg],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const darkGreenDiagonal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkPrimary, darkMid, darkAccent],
    stops: [0.0, 0.45, 1.0],
  );
  static const darkGreenRadialGlow = RadialGradient(
    center: Alignment(-1.0, -1.0),
    radius: 1.5,
    colors: [darkBg, darkMid, darkPrimary],
    stops: [0.0, 0.4, 1.0],
  );
}

class Pathama extends StatefulWidget {
  const Pathama({super.key});

  @override
  State<Pathama> createState() => _PathamaState();
}

class _PathamaState extends State<Pathama> {
  ThemeMode _themeMode = ThemeMode.light;
  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pathama',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Warna.lightBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Warna.lightPrimary,
          brightness: Brightness.light,
          primary: Warna.lightPrimary,
          surface: Warna.lightBoxPrimary,
          surfaceContainerHigh: Warna.lightBoxSecondary,
          outline: Warna.lightBorder,
          onSurface: Warna.lightTextPrimary,
          onSurfaceVariant: Warna.lightTextSecondary,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Warna.darkBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Warna.darkPrimary,
          brightness: Brightness.dark,
          primary: Warna.darkPrimary,
          surface: Warna.darkBoxPrimary,
          surfaceContainerHigh: Warna.darkBoxSecondary,
          outline: Warna.darkBorder,
          onSurface: Warna.darkTextPrimary,
          onSurfaceVariant: Warna.darkTextSecondary,
        ),
      ),
      themeMode: _themeMode,
      home: LoginPage(onToggleTheme: _toggleTheme),
    );
  }
}

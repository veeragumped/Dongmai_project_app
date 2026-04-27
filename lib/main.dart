import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gongdong/login/login.dart';
import 'package:gongdong/model/font_provider.dart';
import 'package:gongdong/model/language_provider.dart';
import 'package:gongdong/navbar/NavigationBar/navbar.dart';
import 'firebase_options.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: 'https://lclisozrtocqzrdjpydp.supabase.co',
    anonKey: 'sb_publishable_5CDyzCt351rLE7GApxfQ3g_s1d4hcQZ',
  );

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('successful connect to firebase');
    }
  } catch (e) {
    debugPrint('firebase already connected');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FontProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dongmai',
      theme: ThemeData(),
      initialRoute: '/',
      routes: {'/login': (context) => const Login()},
      home: /*Login()*/ Navbar(),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:siap_tka_sd/core/config/app_theme.dart';
import 'package:siap_tka_sd/pages/home_page.dart';
import 'package:siap_tka_sd/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = createTextTheme(context, "Roboto", "Roboto");
    final theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: 'Siap TKA SD',
      theme: theme.light(),
      darkTheme: theme.dark(),
      home: const MyHomePage(title: 'Siap TKA SD'),
      debugShowCheckedModeBanner: false,
    );
  }

  TextTheme createTextTheme(BuildContext context, String bodyFontString, String displayFontString) {
    TextTheme baseTextTheme = Theme.of(context).textTheme;
    return baseTextTheme;
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'config/firebase.dart';

import 'config/theme.dart';
import 'services/authentication.dart';
import 'views/layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  await handleGoogleAuthRedirect();
  await handleEmailLink();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      themeMode: ThemeMode.system,
      theme: generateThemeData(Brightness.light),
      darkTheme: generateThemeData(Brightness.dark),
      home: const Layout(),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/screens/auth/login_screen.dart';

void main() {
  runApp(const CampKuApp());
}

class CampKuApp extends StatelessWidget {
  const CampKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampKu',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const LoginScreen(),
    );
  }
}

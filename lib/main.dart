import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:campku/firebase_options.dart';
import 'package:campku/screens/auth/login_screen.dart';
import 'package:campku/screens/dashboard/dashboard_screen.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pulihkan sesi yang masih aktif. Data Firestore dimuat setelah login.
  await AuthService.restoreSession();

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
      home: AuthService.currentUser == null
          ? const LoginScreen()
          : const DashboardScreen(),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:campku/firebase_options.dart';
import 'package:campku/screens/auth/login_screen.dart';
import 'package:campku/services/camp_service.dart';
import 'package:campku/services/destination_service.dart';
import 'package:campku/services/seed_service.dart';
import 'package:campku/services/tent_service.dart';
import 'package:campku/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Isi data awal ke Firestore (sekali saja): flutter run --dart-define=SEED=true
  if (const bool.fromEnvironment('SEED')) await seedFirestore();

  DestinationService.instance.start();
  CampService.instance.start();
  TentService.instance.start();

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

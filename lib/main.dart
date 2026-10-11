import 'package:flutter/material.dart';

import 'screens/signIn_page.dart';
import 'services/settings_storage.dart';
import 'theme/app_theme.dart';

const appBackground = Color(0xFFFBFBFE);
const appText = Color(0xFF040316);
const appPrimary = Color(0xFF064200);
const appSecondary = Color(0xFFDDDBFF);
const appAccent = Color(0xFF443DFF);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsStorage.loadSlaSettings();
  runApp(const SlaTaskTrackerApp());
}

class SlaTaskTrackerApp extends StatelessWidget {
  const SlaTaskTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SLA Task Tracker',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SignInPage(),
    );
  }
}

// Will be used to run tests and callers
class MyApp extends SlaTaskTrackerApp {
  const MyApp({super.key});
}
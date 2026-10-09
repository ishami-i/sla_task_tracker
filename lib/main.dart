import 'package:flutter/material.dart';
import 'screens/profile_page.dart';
import 'screens/taskStatistic_page.dart';
import 'theme/app_theme.dart';
import 'utils/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SLA Task Tracker',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routes: {
        ProfilePage.routeName: (_) => const ProfilePage(),
        TaskStatisticPage.routeName: (_) => const TaskStatisticPage(),
      },
      home: const PreviewHome(),
    );
  }
}

class PreviewHome extends StatefulWidget {
  const PreviewHome({super.key});

  @override
  State<PreviewHome> createState() => _PreviewHomeState();
}

class _PreviewHomeState extends State<PreviewHome> {
  int _index = 0;

  static const List<Widget> _pages = [
    TaskStatisticPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.secondary,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
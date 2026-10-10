import 'package:flutter/material.dart';

import '../main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final displayName = userName.isEmpty
        ? 'User'
        : userName[0].toUpperCase() + userName.substring(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: appSecondary,
                    foregroundColor: appAccent,
                    child: Text(
                      displayName[0],
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: appText,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$userName@example.com',
                    style: TextStyle(
                      color: appText.withValues(alpha: 0.65),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Card(
                    elevation: 0,
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(Icons.badge_outlined, color: appAccent),
                      title: Text('Role'),
                      subtitle: Text('Project team member'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

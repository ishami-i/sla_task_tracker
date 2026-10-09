import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_helper.dart';
import '../services/user_session.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../widgets/error_view.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/menu_tile.dart';
import '../widgets/user_avatar.dart';
import 'appSettings_page.dart';
import 'editProfile_page.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  String? _error;
  User? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = await UserSession.loadCurrentUser();
      if (!mounted) return;
      setState(() {
        _user = user;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('Profile load failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load your profile.';
      });
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openEditProfile() async {
    final user = _user;
    if (user == null) return;

    final updated = await Navigator.of(context).push<User>(
      slideUpRoute<User>(EditProfilePage(user: user)),
    );
    if (!mounted || updated == null) return;

    try {
      await DatabaseHelper.instance.updateUser(updated);
      if (!mounted) return;
      setState(() => _user = updated);
      _showSnack('Profile updated');
    } catch (e) {
      debugPrint('Profile save failed: $e');
      if (!mounted) return;
      _showSnack('Could not save your profile');
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(slideUpRoute(const AppSettingsPage()));
    if (!mounted) return;
    _load();
  }

  void _openAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'SLA Task Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: const CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Icon(Icons.timer_outlined, color: Colors.white),
      ),
      applicationLegalese: 'Project & SLA task tracker\nALU Formative 1 group project',
    );
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will go back to the user selection screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;
    await UserSession.clear();
    if (!mounted) return;
    _showSnack('Signed out');
  }

  Widget _buildContent(User user) {
    const menuDivider = Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.divider,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        FadeSlideIn(
          child: Center(
            child: Hero(
              tag: profileAvatarHeroTag,
              child: Material(
                type: MaterialType.transparency,
                child: UserAvatar(
                  name: user.name,
                  avatarUrl: user.avatarUrl,
                  radius: 44,
                  backgroundColor: AppColors.accent,
                  textColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: Text(
            user.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FadeSlideIn(
          delay: const Duration(milliseconds: 140),
          child: Text(
            user.role,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ),
        const SizedBox(height: 28),
        FadeSlideIn(
          delay: const Duration(milliseconds: 220),
          child: Material(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Column(
              children: [
                MenuTile(
                  icon: Icons.edit_outlined,
                  label: 'Edit Profile',
                  onTap: _openEditProfile,
                ),
                menuDivider,
                MenuTile(
                  icon: Icons.settings_outlined,
                  label: 'App Settings',
                  onTap: _openSettings,
                ),
                menuDivider,
                MenuTile(
                  icon: Icons.info_outline_rounded,
                  label: 'About',
                  onTap: _openAbout,
                ),
                menuDivider,
                MenuTile(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  onTap: _confirmSignOut,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final user = _user;
    if (_error != null || user == null) {
      return ErrorView(
        message: _error ?? 'Could not load your profile.',
        onRetry: () {
          setState(() => _loading = true);
          _load();
        },
      );
    }

    return _buildContent(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(child: _buildBody()),
    );
  }
}
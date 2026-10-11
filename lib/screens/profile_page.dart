import 'package:flutter/material.dart';
import '../logic/sla_calculator.dart';
import '../models/sla_status.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../services/database_helper.dart';
import '../services/user_session.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../utils/date_format.dart';
import '../widgets/error_view.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/menu_tile.dart';
import '../widgets/sla_badge.dart';
import '../widgets/user_avatar.dart';
import 'appSettings_page.dart';
import 'editProfile_page.dart';
import 'signIn_page.dart';
import 'taskDetail_page.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  final String? userName;
  final int? viewUserId;

  const ProfilePage({super.key, this.userName, this.viewUserId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  String? _error;
  User? _user;
  List<Task> _tasks = [];

  bool get _isViewingOther => widget.viewUserId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final db = DatabaseHelper.instance;
      final User? user = _isViewingOther
          ? await db.getUserById(widget.viewUserId!)
          : await UserSession.loadCurrentUser(preferredName: widget.userName);
      final allTasks = await db.getTasks();
      if (!mounted) return;

      if (user == null) {
        setState(() {
          _loading = false;
          _error = 'This team member no longer exists.';
        });
        return;
      }

      setState(() {
        _user = user;
        _tasks = allTasks.where((t) => t.assignedTo == user.id).toList();
        _loading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('Profile load failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load this profile.';
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

  Future<void> _openTask(Task task) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => TaskDetailPage(task: task)),
    );
    if (mounted) _load();
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
        content: const Text('You will go back to the sign in screen.'),
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

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const SignInPage()),
      (route) => false,
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Signed out')));
  }

  int _count(SlaStatus status) {
    final now = DateTime.now();
    return _tasks.where((t) => calculateSlaStatus(t, now: now) == status).length;
  }

  List<Task> _sortedTasks() {
    final open = _tasks.where((t) => !isTaskDone(t.status)).toList()
      ..sort((a, b) {
        final da = parseDeadline(a.deadline);
        final db = parseDeadline(b.deadline);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });
    final done = _tasks.where((t) => isTaskDone(t.status));
    return [...open, ...done];
  }

  Widget _buildStatTile(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _buildStatTile('Assigned', _tasks.length, AppColors.text),
        const SizedBox(width: 8),
        _buildStatTile('Completed', _count(SlaStatus.completed),
            SlaStatus.completed.foreground),
        const SizedBox(width: 8),
        _buildStatTile('At Risk', _count(SlaStatus.atRisk),
            SlaStatus.atRisk.foreground),
        const SizedBox(width: 8),
        _buildStatTile('Overdue', _count(SlaStatus.overdue),
            SlaStatus.overdue.foreground),
      ],
    );
  }

  Widget _buildAssignedTasks() {
    final tasks = _sortedTasks().take(5).toList();
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned tasks',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'No tasks assigned yet.',
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ),
          for (final task in tasks)
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () => _openTask(task),
              title: Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _deadlineText(task),
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              trailing: SlaBadge(status: calculateSlaStatus(task, now: now)),
            ),
        ],
      ),
    );
  }

  String _deadlineText(Task task) {
    final due = parseDeadline(task.deadline);
    final date = due == null ? task.deadline : formatShortDate(due);
    return '${task.priority} · $date';
  }

  Widget _buildMenu() {
    const menuDivider = Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.divider,
    );

    return Material(
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
    );
  }

  Widget _buildContent(User user) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
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
          const SizedBox(height: 24),
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: _buildStats(),
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: const Duration(milliseconds: 260),
            child: _buildAssignedTasks(),
          ),
          if (!_isViewingOther) ...[
            const SizedBox(height: 16),
            FadeSlideIn(
              delay: const Duration(milliseconds: 320),
              child: _buildMenu(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final user = _user;
    if (_error != null || user == null) {
      return ErrorView(
        message: _error ?? 'Could not load this profile.',
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
      appBar: AppBar(title: Text(_isViewingOther ? 'Team Member' : 'Profile')),
      body: SafeArea(child: _buildBody()),
    );
  }
}

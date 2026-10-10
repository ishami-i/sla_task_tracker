import 'package:flutter/material.dart';

import '../main.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import '../services/user_session.dart';
import 'profile_page.dart';
import 'signIn_page.dart';
import 'taskList_page.dart';
import 'taskStatistic_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.userName});

  final String userName;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  List<Task> _tasks = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await DatabaseHelper.instance.getTasks();
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load tasks: $error')),
      );
    }
  }

  int _count(String status) =>
      _tasks.where((task) => task.slaStatus.toLowerCase() == status).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildNavigationDrawer(context),
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Open menu',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu_rounded),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              tooltip: 'View signed-in user',
              onPressed: _showSignedInUser,
              icon: CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: appAccent,
                child: Text(
                  widget.userName.isEmpty
                      ? 'U'
                      : widget.userName[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: [
            Text(
              'Good morning,',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: appText,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              '${_displayName(widget.userName)}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: appText,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Here's what's happening with yourproject.",
              style: TextStyle(
                color: appText.withValues(alpha: 0.65),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildTaskOverview(),
              const SizedBox(height: 18),
              _buildRecentActivity(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              setState(() => _selectedIndex = 0);
            case 1:
              _openTasks();
            case 2:
              _showComingSoon('Team');
            case 3:
              _openStatistics();
            case 4:
              _openProfile();
          }
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.check_box_outlined), label: 'Tasks'),
          NavigationDestination(
              icon: Icon(Icons.groups_outlined), label: 'Team'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined), label: 'Stats'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  String _displayName(String value) {
    if (value.isEmpty) return 'there';
    return value[0].toUpperCase() + value.substring(1);
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    final displayName = _displayName(widget.userName);
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              decoration: const BoxDecoration(color: appPrimary),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: appPrimary,
                child: Text(
                  displayName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              accountName: Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              accountEmail: Text('${widget.userName}@example.com'),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Dashboard'),
              selected: true,
              selectedColor: appPrimary,
              onTap: () {
                Navigator.of(context).pop();
                setState(() => _selectedIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_box_outlined),
              title: const Text('Tasks'),
              onTap: () {
                Navigator.of(context).pop();
                _openTasks();
              },
            ),
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: const Text('Team'),
              onTap: () {
                Navigator.of(context).pop();
                _showComingSoon('Team');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined),
              title: const Text('Statistics'),
              onTap: () {
                Navigator.of(context).pop();
                _openStatistics();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.of(context).pop();
                _openProfile();
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Sign out'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$section is being built by the team.')),
    );
  }

  Future<void> _openStatistics() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TaskStatisticPage()),
    );
    if (mounted) _loadTasks();
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfilePage(userName: widget.userName),
      ),
    );
    if (mounted) _loadTasks();
  }

  Future<void> _signOut() async {
    await UserSession.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const SignInPage()),
      (route) => false,
    );
  }

  void _showSignedInUser() {
    final displayName = _displayName(widget.userName);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signed-in user'),
        content: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: appSecondary,
            foregroundColor: appAccent,
            child: Text(displayName[0].toUpperCase()),
          ),
          title: Text(displayName),
          subtitle: Text('${widget.userName}@example.com'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 4 ? 1.35 : 1.7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
                label: 'Total Tasks',
                value: '${_tasks.length}',
                icon: Icons.assignment_outlined,
                color: appAccent,
                onTap: _openTasks),
            _StatCard(
                label: 'On Track',
                value: '${_count('on track')}',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF16885B),
                onTap: _openTasks),
            _StatCard(
                label: 'At Risk',
                value: '${_count('at risk')}',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFE6A51F),
                onTap: _openTasks),
            _StatCard(
                label: 'Overdue',
                value: '${_count('overdue')}',
                icon: Icons.error_outline,
                color: const Color(0xFFD84949),
                onTap: _openTasks),
          ],
        );
      },
    );
  }

  void _openTasks() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TaskListPage(userName: widget.userName),
      ),
    );
  }

  Widget _buildTaskOverview() {
    final completed = _count('completed');
    return _DashboardCard(
      title: 'Task Overview',
      child: _tasks.isEmpty
          ? const _EmptyState(
              icon: Icons.assignment_outlined,
              message: 'No tasks yet. Create a task to see project progress.',
            )
          : Row(
              children: [
                SizedBox(
                  height: 130,
                  width: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: completed / _tasks.length,
                        strokeWidth: 16,
                        backgroundColor: appSecondary,
                        color: appAccent,
                      ),
                      Text('${_tasks.length}\nTasks',
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendRow('On Track', _count('on track'),
                          const Color(0xFF16885B)),
                      _LegendRow('At Risk', _count('at risk'),
                          const Color(0xFFE6A51F)),
                      _LegendRow('Overdue', _count('overdue'),
                          const Color(0xFFD84949)),
                      _LegendRow('Completed', completed, Colors.blueGrey),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRecentActivity() {
    return _DashboardCard(
      title: 'Recent Activity',
      child: _tasks.isEmpty
          ? const _EmptyState(
              icon: Icons.history_rounded,
              message: 'Your latest task activity will appear here.',
            )
          : Column(
              children: _tasks.take(3).map((task) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: appSecondary,
                    child: Icon(Icons.task_alt, color: appAccent),
                  ),
                  title: Text(task.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${task.slaStatus} • ${task.deadline}'),
                );
              }).toList(),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 25),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: appText,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        color: appText.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: appAccent, size: 30),
        const SizedBox(width: 12),
        Expanded(
            child: Text(message,
                style: TextStyle(color: appText.withValues(alpha: 0.68)))),
      ],
    );
  }
}

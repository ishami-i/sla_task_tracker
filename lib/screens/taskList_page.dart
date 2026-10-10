import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../services/database_helper.dart';
import '../widgets/sla_chip.dart';
import 'profile_page.dart';
import 'taskStatistic_page.dart';
import 'teamMember_page.dart';

class _TaskData {
  final List<Task> tasks;
  final Map<int, User> users;
  _TaskData(this.tasks, this.users);
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key, required this.userName});

  final String userName;

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  SlaStatus? _filter; // null = All
  late Future<_TaskData> _future;

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_TaskData> _load() async {
    final tasks = await DatabaseHelper.instance.getTasks();
    final users = await DatabaseHelper.instance.getUsers();
    return _TaskData(tasks, {
      for (final u in users)
        if (u.id != null) u.id!: u,
    });
  }

  DateTime? _due(Task t) => DateTime.tryParse(t.deadline);

  bool _isDone(Task t) => t.status.toLowerCase().contains('complet');

  SlaStatus _sla(Task t) {
    final due = _due(t);
    if (due == null) {
      return _isDone(t) ? SlaStatus.completed : SlaStatus.onTrack;
    }
    return slaFor(due, _isDone(t));
  }

  String _fmt(Task t) {
    final d = _due(t);
    if (d == null) return t.deadline;
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  List<Task> _apply(List<Task> all) {
    final list = all.where((t) {
      final matchSearch = t.title.toLowerCase().contains(_query.toLowerCase());
      final matchFilter = _filter == null || _sla(t) == _filter;
      return matchSearch && matchFilter;
    }).toList();
    list.sort((a, b) {
      final da = _due(a), db = _due(b);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });
    return list;
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.isEmpty || p.first.isEmpty) return '?';
    return p.length > 1
        ? '${p.first[0]}${p.last[0]}'.toUpperCase()
        : p.first[0].toUpperCase();
  }

  Widget _chip(String label, SlaStatus? value) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: _filter == value,
          onSelected: (_) => setState(() => _filter = value),
        ),
      );

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _chip('All', null),
              _chip('On Track', SlaStatus.onTrack),
              _chip('At Risk', SlaStatus.atRisk),
              _chip('Overdue', SlaStatus.overdue),
              _chip('Completed', SlaStatus.completed),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<_TaskData>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Could not load tasks: ${snap.error}'));
                }
                final data = snap.data!;
                final tasks = _apply(data.tasks);
                if (tasks.isEmpty) return const Center(child: Text('No tasks found'));
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() => _future = _load());
                    await _future;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: tasks.length,
                    itemBuilder: (context, i) {
                      final t = tasks[i];
                      final assignee = data.users[t.assignedTo];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          onTap: () {
                            // TODO: navigate to taskDetail_page
                          },
                          leading: CircleAvatar(
                            child: Text(assignee == null ? '?' : _initials(assignee.name)),
                          ),
                          title: Text(t.title,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '${assignee?.name ?? 'Unassigned'}\n${_fmt(t)}'),
                          isThreeLine: true,
                          trailing: SlaChip(status: _sla(t)),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navigate to create_page, then reload:
          // setState(() => _future = _load());
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pop();
            case 2:
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const TeamMemberPage(),
                ),
              );
            case 3:
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const TaskStatisticPage(),
                ),
              );
            case 4:
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProfilePage(userName: widget.userName),
                ),
              );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_box_outlined),
            selectedIcon: Icon(Icons.check_box),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            label: 'Team',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
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
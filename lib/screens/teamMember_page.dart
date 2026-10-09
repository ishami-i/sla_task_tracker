import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_helper.dart';
import '../services/user_queries.dart';

class TeamMemberPage extends StatefulWidget {
  const TeamMemberPage({super.key});

  @override
  State<TeamMemberPage> createState() => _TeamMemberPageState();
}

class _TeamMemberPageState extends State<TeamMemberPage> {
  late Future<List<User>> _future;

  static const _colors = [
    Colors.blue, Colors.green, Colors.purple, Colors.teal, Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper.instance.getUsers();
  }

  void _reload() =>
      setState(() => _future = DatabaseHelper.instance.getUsers());

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.isEmpty || p.first.isEmpty) return '?';
    return p.length > 1
        ? '${p.first[0]}${p.last[0]}'.toUpperCase()
        : p.first[0].toUpperCase();
  }

  void _showMemberDialog({User? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final roleCtrl = TextEditingController(text: existing?.role ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Member' : 'Edit Member'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            TextFormField(
              controller: roleCtrl,
              decoration: const InputDecoration(labelText: 'Role'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Role is required' : null,
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final db = DatabaseHelper.instance;
              final name = nameCtrl.text.trim();
              final role = roleCtrl.text.trim();
              try {
                if (existing == null) {
                  await db.insertUser(User(name: name, role: role));
                } else {
                  await db.updateUser(User(
                    id: existing.id,
                    name: name,
                    role: role,
                    avatarUrl: existing.avatarUrl,
                  ));
                }
                if (ctx.mounted) Navigator.pop(ctx);
                _reload();
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Could not save member: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(User u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove member?'),
        content: Text('Remove ${u.name}? Their tasks will become unassigned.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (u.id != null) await DatabaseHelper.instance.deleteUser(u.id!);
              if (ctx.mounted) Navigator.pop(ctx);
              _reload();
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.blue),
            onPressed: () => _showMemberDialog(),
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Could not load members: ${snap.error}'));
          }
          final members = snap.data ?? [];
          if (members.isEmpty) {
            return const Center(child: Text('No team members yet. Tap + to add one.'));
          }
          return ListView.separated(
            itemCount: members.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = members[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _colors[i % _colors.length],
                  child: Text(_initials(m.name),
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(m.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(m.role),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') _showMemberDialog(existing: m);
                    if (v == 'delete') _confirmDelete(m);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Remove')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
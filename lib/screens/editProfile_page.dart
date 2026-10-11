import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/app_colors.dart';
import '../utils/profile_validator.dart';
import '../widgets/user_avatar.dart';

const List<String> teamRoles = [
  'Project Lead',
  'Backend Developer',
  'Flutter Developer',
  'UI/UX Designer',
  'QA Tester',
];

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _avatarController;
  late final List<String> _roleOptions;
  String? _role;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    final currentRole = widget.user.role.trim();
    _roleOptions = currentRole.isEmpty || teamRoles.contains(currentRole)
        ? teamRoles
        : [...teamRoles, currentRole];
    _role = currentRole.isEmpty ? null : currentRole;

    _nameController = TextEditingController(text: widget.user.name);
    _avatarController = TextEditingController(text: widget.user.avatarUrl ?? '');
    _nameController.addListener(_refresh);
    _avatarController.addListener(_refresh);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  bool get _hasChanges {
    return _nameController.text.trim() != widget.user.name ||
        _role != widget.user.role ||
        _avatarController.text.trim() != (widget.user.avatarUrl ?? '');
  }

  String? get _previewUrl {
    final text = _avatarController.text.trim();
    if (text.isEmpty || ProfileValidator.validateAvatarUrl(text) != null) {
      return null;
    }
    return text;
  }

  void _save() {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Please fix the highlighted fields')),
        );
      return;
    }

    final avatar = _avatarController.text.trim();
    Navigator.of(context).pop(
      User(
        id: widget.user.id,
        name: _nameController.text.trim(),
        role: _role!,
        avatarUrl: avatar.isEmpty ? null : avatar,
      ),
    );
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;

    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits to this profile will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (discard == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final previewName =
        _nameController.text.trim().isEmpty ? '?' : _nameController.text;

    return PopScope<Object?>(
      canPop: !_hasChanges,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                Center(
                  child: Hero(
                    tag: profileAvatarHeroTag,
                    child: Material(
                      type: MaterialType.transparency,
                      child: UserAvatar(
                        name: previewName,
                        avatarUrl: _previewUrl,
                        radius: 44,
                        backgroundColor: AppColors.accent,
                        textColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Live preview',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full name *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  maxLength: 40,
                  validator: ProfileValidator.validateName,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: const InputDecoration(
                    labelText: 'Role *',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  items: [
                    for (final role in _roleOptions)
                      DropdownMenuItem(value: role, child: Text(role)),
                  ],
                  onChanged: (value) => setState(() => _role = value),
                  validator: ProfileValidator.validateRole,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _avatarController,
                  decoration: const InputDecoration(
                    labelText: 'Avatar image link (optional)',
                    hintText: 'https://…',
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  validator: ProfileValidator.validateAvatarUrl,
                  onFieldSubmitted: (_) => _save(),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: FilledButton(
              onPressed: _hasChanges ? _save : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: const Text('Save changes'),
            ),
          ),
        ),
      ),
    );
  }
}
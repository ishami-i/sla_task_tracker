class User {
  final int? id;
  final String name;
  final String role;
  final String? avatarUrl;

  User({this.id, required this.name, required this.role, this.avatarUrl});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'role': role,
      'avatar_url': avatarUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      role: map['role'] as String,
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}

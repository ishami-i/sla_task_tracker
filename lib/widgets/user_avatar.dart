import 'package:flutter/material.dart';
import '../utils/initials.dart';

const String profileAvatarHeroTag = 'profile-avatar';

class UserAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double radius;
  final Color backgroundColor;
  final Color textColor;

  const UserAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 24,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;

    final initialsCircle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Text(
        initialsOf(name),
        style: TextStyle(
          fontSize: radius * 0.64,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );

    final url = avatarUrl;
    if (url == null || url.isEmpty) return initialsCircle;

    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : initialsCircle,
        errorBuilder: (context, error, stackTrace) => initialsCircle,
      ),
    );
  }
}
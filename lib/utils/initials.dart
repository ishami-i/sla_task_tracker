String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  final result = parts.take(2).map((p) => p[0].toUpperCase()).join();
  return result.isEmpty ? '?' : result;
}
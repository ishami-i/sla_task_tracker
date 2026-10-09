class ProfileValidator {
  static final RegExp _allowedNameChars = RegExp(r"^[A-Za-zÀ-ÿ' -]+$");
  static final RegExp _hasLetter = RegExp(r'[A-Za-zÀ-ÿ]');

  static String? validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Name is required';
    if (text.length < 2) return 'Name must be at least 2 characters';
    if (text.length > 40) return 'Name must be 40 characters or fewer';
    if (!_allowedNameChars.hasMatch(text)) {
      return 'Use letters, spaces, hyphens or apostrophes only';
    }
    if (!_hasLetter.hasMatch(text)) return 'Name must contain letters';
    return null;
  }

  static String? validateRole(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please choose a role';
    return null;
  }

  static String? validateAvatarUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    final isValid = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return isValid ? null : 'Enter a link starting with http:// or https://';
  }
}
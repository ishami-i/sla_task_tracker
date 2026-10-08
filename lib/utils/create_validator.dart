class CreateValidator {
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a task title';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a description';
    }
    return null;
  }

  static String? validateUser(int? value) {
    if (value == null) {
      return 'Please select an assigned user';
    }
    return null;
  }

  static String? validateDeadline(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a deadline date';
    }
    return null;
  }

  static String? validatePriority(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a priority level';
    }
    return null;
  }

  static String? validateStatus(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a status';
    }
    return null;
  }
}

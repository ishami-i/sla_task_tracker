const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _twoDigits(int n) => n.toString().padLeft(2, '0');

String formatShortDate(DateTime date) {
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}

String formatTimeLeft(Duration left) {
  if (left.isNegative) return 'overdue';
  if (left.inHours < 48) return 'in ${left.inHours} h';
  return 'in ${left.inDays} days';
}

String formatDeadlineForStorage(DateTime date) {
  return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)} '
      '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
}
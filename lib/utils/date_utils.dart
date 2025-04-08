import 'package:intl/intl.dart';

String formatMonthYear(int? month, int? year) {
  if (month == null || year == null) return 'Select Date';
  return '${DateFormat('MMMM').format(DateTime(0, month))} $year';
}
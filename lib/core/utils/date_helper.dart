import 'package:intl/intl.dart';

/// Shared helper for date/time formatting
///
/// Usage:
/// ```dart
/// String formatted = DateHelper.formatDate(date);
/// String formatted = DateHelper.formatDateTime(date);
/// String formatted = DateHelper.formatTime(date);
/// ```
class DateHelper {
  DateHelper._();

  /// Indonesian locale
  static const _locale = 'id';

  /// Format date to "dd MMMM yyyy" (e.g., "20 Juni 2026")
  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', _locale).format(date);
  }

  /// Format date to "dd/MM/yyyy" (e.g., "20/06/2026")
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date to "yyyy-MM-dd" (API format)
  static String formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format datetime to "dd MMMM yyyy, HH:mm" (e.g., "20 Juni 2026, 14:30")
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMMM yyyy, HH:mm', _locale).format(date);
  }

  /// Format time to "HH:mm" (e.g., "14:30")
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format time range (e.g., "08:00 - 10:00")
  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  /// Format date with relative indicator (e.g., "Hari ini", "Kemarin", or date)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Kemarin';
    } else if (difference == -1) {
      return 'Besok';
    } else if (difference > 1 && difference <= 7) {
      return DateFormat('EEEE', _locale).format(date); // Day name
    } else {
      return formatDate(date);
    }
  }

  /// Format date for display in lists (compact)
  static String formatDateCompact(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'Hari ini, ${formatTime(date)}';
    } else if (difference == 1) {
      return 'Kemarin, ${formatTime(date)}';
    } else if (difference > 1 && difference <= 7) {
      return '${DateFormat('EEEE', _locale).format(date)}, ${formatTime(date)}';
    } else {
      return '${formatDateShort(date)}, ${formatTime(date)}';
    }
  }

  /// Parse date string from API response (handles various formats)
  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  /// Get day name in Indonesian
  static String getDayName(DateTime date) {
    return DateFormat('EEEE', _locale).format(date);
  }

  /// Get short day name in Indonesian (e.g., "Sen", "Sel")
  static String getDayNameShort(DateTime date) {
    return DateFormat('EE', _locale).format(date);
  }

  /// Get month name in Indonesian
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM', _locale).format(date);
  }

  /// Get short month name in Indonesian (e.g., "Jan", "Feb")
  static String getMonthNameShort(DateTime date) {
    return DateFormat('MMM', _locale).format(date);
  }
}

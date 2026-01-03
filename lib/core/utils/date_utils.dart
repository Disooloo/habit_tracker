class DateUtils {
  /// Format date to YYYY-MM-DD string
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Parse YYYY-MM-DD string to DateTime
  static DateTime parseDate(String dateString) {
    final parts = dateString.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Get today's date as YYYY-MM-DD string
  static String today() {
    return formatDate(DateTime.now());
  }

  /// Get start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get day of week name (Monday, Tuesday, etc.)
  static String getDayOfWeekName(DateTime date) {
    const days = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    return days[date.weekday - 1];
  }

  /// Get day of week name in English
  static String getDayOfWeekNameEn(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  /// Get list of dates for the last N days
  static List<DateTime> getLastNDays(int n) {
    final now = DateTime.now();
    return List.generate(n, (index) {
      return DateTime(now.year, now.month, now.day).subtract(Duration(days: n - 1 - index));
    });
  }

  /// Get list of date strings for the last N days
  static List<String> getLastNDaysStrings(int n) {
    return getLastNDays(n).map((date) => formatDate(date)).toList();
  }

  /// Get week number (1-7) for a date
  static int getWeekday(DateTime date) {
    return date.weekday;
  }
}



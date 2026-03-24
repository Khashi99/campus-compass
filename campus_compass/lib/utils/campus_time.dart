class CampusTime {
  CampusTime._();

  static DateTime toEastern(DateTime value) {
    final utc = value.toUtc();
    final offsetHours = _isEasternDstUtc(utc) ? -4 : -5;
    return utc.add(Duration(hours: offsetHours));
  }

  static DateTime easternDateAndTimeToUtc({
    required DateTime date,
    required int hour,
    required int minute,
  }) {
    final easternWallClock = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
    final offsetHours = _isEasternDstLocal(easternWallClock) ? -4 : -5;
    return DateTime.utc(date.year, date.month, date.day, hour, minute)
        .subtract(Duration(hours: offsetHours));
  }

  static String zoneAbbreviation(DateTime value) {
    return _isEasternDstUtc(value.toUtc()) ? 'EDT' : 'EST';
  }

  static String formatDetailed(DateTime value) {
    final eastern = toEastern(value);
    final nowEastern = toEastern(DateTime.now());
    final today = DateTime(nowEastern.year, nowEastern.month, nowEastern.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(eastern.year, eastern.month, eastern.day);

    late final String dateStr;
    if (dateToCheck == today) {
      dateStr = 'Today';
    } else if (dateToCheck == yesterday) {
      dateStr = 'Yesterday';
    } else {
      final month = eastern.month.toString().padLeft(2, '0');
      final day = eastern.day.toString().padLeft(2, '0');
      dateStr = '$month/$day/${eastern.year}';
    }

    final hour = eastern.hour.toString().padLeft(2, '0');
    final minute = eastern.minute.toString().padLeft(2, '0');
    return '$dateStr at $hour:$minute ${zoneAbbreviation(value)}';
  }

  static String formatCompact(DateTime value) {
    final eastern = toEastern(value);
    final year = eastern.year.toString();
    final month = eastern.month.toString().padLeft(2, '0');
    final day = eastern.day.toString().padLeft(2, '0');
    final hour = eastern.hour.toString().padLeft(2, '0');
    final minute = eastern.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute ${zoneAbbreviation(value)}';
  }

  static bool _isEasternDstUtc(DateTime utc) {
    final year = utc.year;
    final dstStartUtc = DateTime.utc(year, 3, _nthSunday(year, 3, 2), 7);
    final dstEndUtc = DateTime.utc(year, 11, _nthSunday(year, 11, 1), 6);
    return !utc.isBefore(dstStartUtc) && utc.isBefore(dstEndUtc);
  }

  static bool _isEasternDstLocal(DateTime easternWallClock) {
    final year = easternWallClock.year;
    final dstStartLocal = DateTime(year, 3, _nthSunday(year, 3, 2), 2);
    final dstEndLocal = DateTime(year, 11, _nthSunday(year, 11, 1), 2);
    return !easternWallClock.isBefore(dstStartLocal) &&
        easternWallClock.isBefore(dstEndLocal);
  }

  static int _nthSunday(int year, int month, int occurrence) {
    final firstDay = DateTime(year, month, 1);
    final offset = (DateTime.sunday - firstDay.weekday + 7) % 7;
    return 1 + offset + ((occurrence - 1) * 7);
  }
}

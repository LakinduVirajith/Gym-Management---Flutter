class AppDateUtils {
  /// ADDS A SPECIFIED NUMBER OF MONTHS TO A DATE, HANDLING MONTH OVERFLOW.
  static DateTime addMonths(DateTime date, int monthsToAdd) {
    int year = date.year;
    int month = date.month + monthsToAdd;
    int day = date.day;

    while (month > 12) {
      month -= 12;
      year++;
    }

    int lastDay = DateTime(year, month + 1, 0).day;
    if (day > lastDay) {
      day = lastDay;
    }

    return DateTime(year, month, day);
  }

  /// CALCULATES AGE IN YEARS BASED ON A BIRTHDAY
  static int calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;

    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }

    return age;
  }

  /// RETURNS THE NUMBER OF MONTHS CORRESPONDING TO A GIVEN SIBSCRIPTION PLAN.
  static int getMonthsFromPlan(String plan) {
    switch (plan.toLowerCase()) {
      case '1month':
      case '1 Month Plan':
        return 1;

      case '3months':
      case '3 Months Plan':
        return 3;

      case '6months':
      case '6 Months Plan':
        return 6;

      case '1year':
      case '1 Year Plan':
        return 12;

      default:
        return 1;
    }
  }

  /// CONVERTS RAW FIRESTORE PLAN KEYS INTO READABLE LABELS
  static String formatPlanLabel(String rawKey) {
    final RegExp regex = RegExp(r'(\d+)\s*([a-zA-Z]+)');
    final match = regex.firstMatch(rawKey);

    if (match != null) {
      final number = int.tryParse(match.group(1) ?? '1') ?? 1;
      final unit = match.group(2)?.toLowerCase();

      String formattedUnit;
      if (unit == 'month' || unit == 'months') {
        formattedUnit = number == 1 ? 'Month' : 'Months';
      } else if (unit == 'year' || unit == 'years') {
        formattedUnit = number == 1 ? 'Year' : 'Years';
      } else {
        formattedUnit = unit ?? '';
      }

      return '$number $formattedUnit Plan';
    }

    return '${rawKey[0].toUpperCase()}${rawKey.substring(1)} Plan';
  }
}

class AppDateUtils {
  /// ADDS ONE MONTH TO THE GIVEN DATE, ADJUSTING FOR END-OF-MONTH OVERFLOWS
  static DateTime addOneMonth(DateTime date) {
    int year = date.year;
    int month = date.month + 1;
    int day = date.day;

    // HANDLE YEAR WRAP IF MONTH > 12
    if (month > 12) {
      month = 1;
      year++;
    }

    // GET LAST VALID DAY OF TARGET MONTH
    int lastDayOfNextMonth = DateTime(year, month + 1, 0).day;

    // CLAMP DAY TO LAST DAY OF TARGET MONTH
    if (day > lastDayOfNextMonth) {
      day = lastDayOfNextMonth;
    }

    return DateTime(year, month, day);
  }

  /// CALCULATES AGE IN YEARS BASED ON A BIRTHDAY
  static int calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;

    // ADJUST IF BIRTHDAY HAS NOT OCCURRED YET THIS YEAR
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }

    return age;
  }
}

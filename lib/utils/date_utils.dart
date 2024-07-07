class AppDateUtils {
  static DateTime addOneMonth(DateTime date) {
    int year = date.year;
    int month = date.month + 1;
    int day = date.day;

    // If adding one month exceeds December, wrap around to January of the next year
    if (month > 12) {
      month = 1;
      year++;
    }

    // Calculate the last day of the next month
    int lastDayOfNextMonth = DateTime(year, month + 1, 0).day;

    // Adjust the day if it exceeds the last day of the next month
    if (day > lastDayOfNextMonth) {
      day = lastDayOfNextMonth;
    }

    return DateTime(year, month, day);
  }
}

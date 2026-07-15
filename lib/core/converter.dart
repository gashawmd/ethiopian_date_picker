/// Low-level calendar math for converting between the Gregorian calendar,
/// Julian Day Numbers (JDN), and the Ethiopian (Ge'ez) calendar.
///
/// The Ethiopian calendar has 13 months: 12 months of exactly 30 days,
/// plus Pagumē, a short 13th month of 5 days (6 in an Ethiopian leap year).
///
/// The algorithm below is anchored to a historically verified date: the
/// Ethiopian Millennium, celebrated on 11 September 2007 (Gregorian),
/// which is Meskerem 1, 2000 on the Ethiopian calendar. All conversions
/// are derived algebraically from that anchor and the standard Ethiopian
/// leap-year rule (a year is a leap year when `year % 4 == 3`), which
/// mirrors the historical Julian calendar's leap rule.
library;

/// Julian Day Number offset used to align JDN 0 with the Ethiopian epoch.
///
/// Derived so that Ethiopian date 2000-01-01 (Meskerem 1, 2000) maps to
/// Gregorian 2007-09-11, matching the well documented Ethiopian
/// Millennium celebration.
const int kEthiopianJdnEpochOffset = 1724220;

/// Converts a proleptic Gregorian [year]/[month]/[day] to a Julian Day
/// Number (JDN). Uses the standard Fliegel & Van Flandern algorithm.
int gregorianToJdn(int year, int month, int day) {
  final int a = ((14 - month) / 12).floor();
  final int y = year + 4800 - a;
  final int m = month + 12 * a - 3;
  return day +
      ((153 * m + 2) / 5).floor() +
      365 * y +
      (y / 4).floor() -
      (y / 100).floor() +
      (y / 400).floor() -
      32045;
}

/// Converts a Julian Day Number [jdn] back to a proleptic Gregorian date.
/// Returns a record of (year, month, day).
({int year, int month, int day}) jdnToGregorian(int jdn) {
  final int a = jdn + 32044;
  final int b = ((4 * a + 3) / 146097).floor();
  final int c = a - ((146097 * b) / 4).floor();
  final int d = ((4 * c + 3) / 1461).floor();
  final int e = c - ((1461 * d) / 4).floor();
  final int m = ((5 * e + 2) / 153).floor();
  final int day = e - ((153 * m + 2) / 5).floor() + 1;
  final int month = m + 3 - 12 * (m ~/ 10);
  final int year = 100 * b + d - 4800 + (m ~/ 10);
  return (year: year, month: month, day: day);
}

/// Converts an Ethiopian [year]/[month]/[day] (month 1-13) to a Julian Day
/// Number. Does not validate ranges - use [EthiopianCalendarLogic] for that.
int ethiopianToJdn(int year, int month, int day) {
  return kEthiopianJdnEpochOffset +
      365 * (year - 1) +
      (year / 4).floor() +
      30 * (month - 1) +
      (day - 1);
}

/// Converts a Julian Day Number [jdn] to an Ethiopian date.
/// Returns a record of (year, month, day).
({int year, int month, int day}) jdnToEthiopian(int jdn) {
  final int k = jdn - kEthiopianJdnEpochOffset;
  final int cycles = (k / 1461).floor();
  final int remainder = k - cycles * 1461;

  int year;
  int dayOfYear;
  if (remainder < 365) {
    year = 4 * cycles + 1;
    dayOfYear = remainder;
  } else if (remainder < 730) {
    year = 4 * cycles + 2;
    dayOfYear = remainder - 365;
  } else if (remainder < 1096) {
    year = 4 * cycles + 3;
    dayOfYear = remainder - 730;
  } else {
    year = 4 * cycles + 4;
    dayOfYear = remainder - 1096;
  }

  final int month = (dayOfYear / 30).floor() + 1;
  final int day = dayOfYear % 30 + 1;
  return (year: year, month: month, day: day);
}

import 'ethiopian_date.dart';

extension EthiopianDateTimeX on DateTime {
  EthiopianDate toEthiopianDate() => EthiopianDate.fromGregorian(this);
}

extension EthiopianDateFormatting on EthiopianDate {
  String format([String pattern = 'yyyy-MM-dd']) {
    final String yyyy = year.toString().padLeft(4, '0');
    final String yy = yyyy.substring(yyyy.length - 2);
    final String mm = month.toString().padLeft(2, '0');
    final String dd = day.toString().padLeft(2, '0');

    return pattern
        .replaceAll('yyyy', yyyy)
        .replaceAll('yy', yy)
        .replaceAll('MM', mm)
        .replaceAll('M', month.toString())
        .replaceAll('dd', dd)
        .replaceAll('d', day.toString());
  }
}

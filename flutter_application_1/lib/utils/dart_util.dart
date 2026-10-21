import 'package:intl/intl.dart';

class DateUtil {
  DateUtil._();

  static String getFormetterDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }
}

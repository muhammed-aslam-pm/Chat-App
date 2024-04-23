import 'package:intl/intl.dart';

class HelperFunctions {
  static String formatDate(DateTime date) {
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      // Date is today, output time (e.g., 4:30 pm)
      String formattedTime =
          '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      return DateFormat.jm().format(date); // format time with AM/PM
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      // Date is yesterday
      return 'Yesterday';
    } else {
      // Date is before yesterday, output date in the format 'dd/mm/yy'
      return DateFormat('dd/MM/yy').format(date);
    }
  }
}

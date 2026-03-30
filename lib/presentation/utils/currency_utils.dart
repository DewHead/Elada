import 'package:intl/intl.dart';

class CurrencyUtils {
  static final _formatter = NumberFormat('#,##0.00', 'en_US');

  static String formatAmount(double amount, String currency) {
    if (currency == '€') {
      return _formatter.format(amount);
    }
    return '$currency ${_formatter.format(amount)}';
  }
}

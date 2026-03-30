import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Allow only digits and a single dot
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    if ('.'.allMatches(newText).length > 1) {
      return oldValue;
    }

    if (newText == '.') {
      return const TextEditingValue(
        text: '0.',
        selection: TextSelection.collapsed(offset: 2),
      );
    }

    List<String> parts = newText.split('.');
    String intPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    if (intPart.startsWith('0') && intPart.length > 1) {
      intPart = intPart.replaceFirst(RegExp(r'^0+'), '');
      if (intPart.isEmpty) intPart = '0';
    }

    final formatter = NumberFormat('#,###', 'en_US');
    String formattedInt = intPart.isEmpty
        ? ''
        : formatter.format(int.parse(intPart));

    if (newText.endsWith('.') && decimalPart.isEmpty) {
      decimalPart = '.';
    }

    String finalResult = formattedInt + decimalPart;

    int diff = finalResult.length - newValue.text.length;
    int selectionIndex = newValue.selection.end + diff;

    if (selectionIndex < 0) {
      selectionIndex = 0;
    } else if (selectionIndex > finalResult.length) {
      selectionIndex = finalResult.length;
    }

    return TextEditingValue(
      text: finalResult,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

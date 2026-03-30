import 'package:flutter/services.dart';

class PrefixTextInputFormatter extends TextInputFormatter {
  final String prefix;

  PrefixTextInputFormatter(this.prefix);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new text is shorter than the prefix, it means the user
    // tried to delete part of the prefix. Restore the prefix.
    if (newValue.text.length < prefix.length) {
      return TextEditingValue(
        text: prefix,
        selection: TextSelection.collapsed(offset: prefix.length),
      );
    }

    // If the new text doesn't start with the prefix (e.g., they deleted
    // or changed something at the beginning), restore the old value
    // or the prefix if the old value was also invalid (unlikely).
    if (!newValue.text.startsWith(prefix)) {
      if (oldValue.text.startsWith(prefix)) {
        return oldValue;
      }
      return TextEditingValue(
        text: prefix,
        selection: TextSelection.collapsed(offset: prefix.length),
      );
    }

    // Otherwise, allow the change.
    return newValue;
  }
}

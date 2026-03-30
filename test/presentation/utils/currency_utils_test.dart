import 'package:flutter_test/flutter_test.dart';
import 'package:elada/presentation/utils/currency_utils.dart';

void main() {
  group('CurrencyUtils', () {
    test('should format small amounts with commas and 2 decimals', () {
      expect(CurrencyUtils.formatAmount(100.0, '€'), '100.00');
      expect(CurrencyUtils.formatAmount(100.5, '\$'), '\$ 100.50');
      expect(CurrencyUtils.formatAmount(100.55, '£'), '£ 100.55');
    });

    test('should format large amounts with commas and 2 decimals', () {
      expect(CurrencyUtils.formatAmount(1000.0, '€'), '1,000.00');
      expect(CurrencyUtils.formatAmount(10000.0, '€'), '10,000.00');
      expect(CurrencyUtils.formatAmount(1000000.0, '€'), '1,000,000.00');
    });

    test('should handle zero correctly', () {
      expect(CurrencyUtils.formatAmount(0.0, '€'), '0.00');
    });
  });
}

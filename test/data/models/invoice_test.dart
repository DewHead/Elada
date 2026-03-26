import 'package:flutter_test/flutter_test.dart';
import 'package:elada/data/models/invoice.dart';

void main() {
  group('Invoice Model', () {
    test('should create an Invoice instance', () {
      final date = DateTime.now();
      final invoice = Invoice(
        invoiceNumber: '9418',
        description: 'Test Description',
        total: 1500.0,
        date: date,
        currency: '€',
      );

      expect(invoice.invoiceNumber, '9418');
      expect(invoice.description, 'Test Description');
      expect(invoice.total, 1500.0);
      expect(invoice.effectiveDate, date);
      expect(invoice.currency, '€');
    });

    test('should handle null date gracefully', () {
      final invoice = Invoice(
        invoiceNumber: '9418',
        description: 'Test',
        total: 100.0,
      );

      expect(invoice.date, isNotNull); // Constructor defaults it
      expect(invoice.effectiveDate, isNotNull);
    });

    test('should convert to and from JSON', () {
      final date = DateTime(2026, 3, 25);
      final invoice = Invoice(
        invoiceNumber: '9418',
        description: 'Test Description',
        total: 1500.0,
        date: date,
        currency: '€',
      );

      final json = invoice.toJson();
      expect(json['invoice_number'], '9418');
      expect(json['description'], 'Test Description');
      expect(json['total'], 1500.0);
      expect(json['date'], date.toIso8601String());
      expect(json['currency'], '€');

      final fromJson = Invoice.fromJson(json);
      expect(fromJson.invoiceNumber, invoice.invoiceNumber);
      expect(fromJson.description, invoice.description);
      expect(fromJson.total, invoice.total);
      expect(fromJson.effectiveDate, invoice.effectiveDate);
      expect(fromJson.currency, invoice.currency);
    });
  });
}

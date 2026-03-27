import 'package:hive/hive.dart';

part 'invoice.g.dart';

@HiveType(typeId: 0)
class Invoice extends HiveObject {
  @HiveField(0)
  final String invoiceNumber;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final double total;

  @HiveField(3)
  final DateTime? date; // Made nullable to handle older data gracefully

  @HiveField(4, defaultValue: '€')
  final String currency;

  @HiveField(5, defaultValue: false)
  final bool isDraft;

  Invoice({
    required this.invoiceNumber,
    required this.description,
    required this.total,
    DateTime? date,
    this.currency = '€',
    this.isDraft = false,
  }) : date = date ?? DateTime.now();

  // Helper getter to ensure non-null date in app logic
  DateTime get effectiveDate => date ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'invoice_number': invoiceNumber,
      'description': description,
      'total': total,
      'date': effectiveDate.toIso8601String(),
      'currency': currency,
      'is_draft': isDraft,
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceNumber: json['invoice_number'],
      description: json['description'],
      total: json['total'].toDouble(),
      date: DateTime.tryParse(json['date'] ?? ''),
      currency: json['currency'] ?? '€',
      isDraft: json['is_draft'] ?? false,
    );
  }
}

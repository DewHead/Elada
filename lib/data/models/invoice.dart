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
  final DateTime date;
  
  @HiveField(4)
  final String currency;

  Invoice({
    required this.invoiceNumber,
    required this.description,
    required this.total,
    required this.date,
    this.currency = '€',
  });

  Map<String, dynamic> toJson() {
    return {
      'invoice_number': invoiceNumber,
      'description': description,
      'total': total,
      'date': date.toIso8601String(),
      'currency': currency,
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceNumber: json['invoice_number'],
      description: json['description'],
      total: json['total'].toDouble(),
      date: DateTime.parse(json['date']),
      currency: json['currency'] ?? '€',
    );
  }
}

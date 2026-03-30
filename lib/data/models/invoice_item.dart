import 'package:hive/hive.dart';

part 'invoice_item.g.dart';

@HiveType(typeId: 1)
class InvoiceItem extends HiveObject {
  @HiveField(0)
  final String description;

  @HiveField(1)
  final double price;

  InvoiceItem({required this.description, required this.price});

  Map<String, dynamic> toJson() {
    return {'description': description, 'price': price};
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }
}

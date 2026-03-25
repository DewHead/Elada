import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final _descriptionController = TextEditingController();
  final _totalController = TextEditingController();
  final _invoiceNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<InvoiceProvider>(context, listen: false);
    _invoiceNumberController.text = provider.invoiceNumber;
    _descriptionController.text = provider.description;
    _totalController.text = provider.total > 0 ? provider.total.toString() : '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _totalController.dispose();
    _invoiceNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elada Invoice'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Generate New Invoice',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildInputField(
              controller: _invoiceNumberController,
              label: 'Invoice Number',
              onChanged: (val) => context.read<InvoiceProvider>().updateInvoiceNumber(val),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _descriptionController,
              label: 'Item Description',
              onChanged: (val) => context.read<InvoiceProvider>().updateDescription(val),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _totalController,
              label: 'Total Amount',
              onChanged: (val) {
                final doubleValue = double.tryParse(val) ?? 0.0;
                context.read<InvoiceProvider>().updateTotal(doubleValue);
              },
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixText: '€ ',
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => _generatePdf(context),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate PDF'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    final provider = context.read<InvoiceProvider>();
    
    try {
      // 1. Load template from assets
      final templateData = await DefaultAssetBundle.of(context).load('assets/templates/invoice_template.pdf');
      final templateBytes = templateData.buffer.asUint8List();

      // 2. Generate PDF
      final pdfBytes = await provider.generateInvoice(templateBytes);

      // 3. Save PDF (Simple path for MVP)
      // In a real app, we'd use a file picker or a specific directory
      // For now, let's just show a success message
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice ${provider.invoiceNumber} generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefixText,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/presentation/widgets/invoice_preview.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final _descriptionController = TextEditingController();
  final _totalController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _dateController = TextEditingController();
  late InvoiceProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<InvoiceProvider>(context, listen: false);
    _invoiceNumberController.text = _provider.invoiceNumber;
    _descriptionController.text = _provider.description;
    _totalController.text = _provider.total > 0 ? _provider.total.toString() : '';
    _updateDateController();
    
    // Listen for external updates (e.g., loading a draft)
    _provider.addListener(_onProviderUpdate);

    // Load template for previews
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final templateData = await DefaultAssetBundle.of(context).load('assets/templates/invoice_template.pdf');
        final templateBytes = templateData.buffer.asUint8List();
        _provider.updateTemplateBytes(templateBytes);
      } catch (e) {
        // Handle template loading error
      }
    });
  }

  void _onProviderUpdate() {
    if (!mounted) return;
    
    // Only update if controllers are different from provider state to avoid cursor jumping
    if (_invoiceNumberController.text != _provider.invoiceNumber) {
      _invoiceNumberController.text = _provider.invoiceNumber;
    }
    if (_descriptionController.text != _provider.description) {
      _descriptionController.text = _provider.description;
    }
    final totalStr = _provider.total > 0 ? _provider.total.toString() : '';
    if (_totalController.text != totalStr) {
      _totalController.text = totalStr;
    }
    _updateDateController();
  }

  void _updateDateController() {
    final date = _provider.date;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    if (_dateController.text != formattedDate) {
      _dateController.text = formattedDate;
    }
  }

  @override
  void dispose() {
    // Remove listener using stored reference
    _provider.removeListener(_onProviderUpdate);
    _descriptionController.dispose();
    _totalController.dispose();
    _invoiceNumberController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elada Invoice'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Desktop Side-by-Side
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildForm(context),
                  ),
                ),
                const VerticalDivider(width: 1),
                const Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: InvoicePreview(),
                  ),
                ),
              ],
            );
          } else {
            // Mobile view with FAB for preview
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildForm(context),
                ),
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: FloatingActionButton.extended(
                    onPressed: () => _showPreviewModal(context),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Preview'),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _showPreviewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Invoice Preview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: InvoicePreview(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final provider = context.watch<InvoiceProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Icon(
          Icons.receipt_long_rounded,
          size: 80,
          color: Theme.of(context).colorScheme.primary.withAlpha(204), // ~0.8 opacity
        ),
        const SizedBox(height: 24),
        Text(
          'Generate New Invoice',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Fill in the details for your professional invoice',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        Text(
          'Currency',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: '€', label: Text('€')),
            ButtonSegment(value: '\$', label: Text('\$')),
            ButtonSegment(value: '£', label: Text('£')),
          ],
          selected: {provider.selectedCurrency},
          onSelectionChanged: (Set<String> newSelection) {
            context.read<InvoiceProvider>().updateCurrency(newSelection.first);
          },
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _invoiceNumberController,
          label: 'Invoice Number',
          onChanged: (val) => context.read<InvoiceProvider>().updateInvoiceNumber(val),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _dateController,
          label: 'Invoice Date',
          onChanged: (_) {},
          readOnly: true,
          onTap: () => _selectDate(context),
          prefixIcon: const Icon(Icons.calendar_today_outlined),
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
          prefixText: '${provider.selectedCurrency} ',
        ),
        const SizedBox(height: 48),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _saveDraft(context),
                icon: const Icon(Icons.save_as_outlined),
                label: const Text('Save as Draft'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withAlpha(128),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withAlpha(77),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _generatePdf(context),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate PDF'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => _clearForm(context),
          icon: const Icon(Icons.clear_all),
          label: const Text('Clear Form'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  void _clearForm(BuildContext context) {
    final provider = context.read<InvoiceProvider>();
    provider.updateDescription('');
    provider.updateTotal(0.0);
    provider.updateDate(DateTime.now());
    _descriptionController.clear();
    _totalController.clear();
    _invoiceNumberController.text = provider.invoiceNumber;
    _updateDateController();
  }

  Future<void> _selectDate(BuildContext context) async {
    final provider = context.read<InvoiceProvider>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != provider.date) {
      provider.updateDate(picked);
    }
  }

  Future<void> _saveDraft(BuildContext context) async {
    final provider = context.read<InvoiceProvider>();
    try {
      await provider.saveDraft();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft saved successfully!'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving draft: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generatePdf(BuildContext context) async {
    final provider = context.read<InvoiceProvider>();
    
    try {
      // 1. Load template from assets
      final templateData = await DefaultAssetBundle.of(context).load('assets/templates/invoice_template.pdf');
      final templateBytes = templateData.buffer.asUint8List();

      // 2. Generate PDF
      await provider.generateInvoice(templateBytes);

      // 3. Save PDF (Simple path for MVP)
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice ${provider.invoiceNumber} generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefixText,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(77), // ~0.3 opacity
      ),
    );
  }
}

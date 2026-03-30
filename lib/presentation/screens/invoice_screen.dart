import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/presentation/utils/prefix_formatter.dart';
import 'package:elada/presentation/widgets/invoice_preview.dart';
import 'package:elada/presentation/utils/thousands_formatter.dart';

class InvoiceScreen extends StatefulWidget {
  final bool testing;
  const InvoiceScreen({super.key, this.testing = false});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final _invoiceNumberController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalAmountController = TextEditingController();

  final _invoiceNumberFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _totalAmountFocusNode = FocusNode();

  late InvoiceProvider _provider;

  // Track previous values to detect changes that require UI rebuild (excluding text fields)
  String? _lastCurrency;
  bool? _lastIsGenerating;
  DateTime? _lastDate;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<InvoiceProvider>(context, listen: false);

    // Initial controller setup
    _invoiceNumberController.text = _provider.invoiceNumber;
    _descriptionController.text = _provider.items.isNotEmpty
        ? _provider.items[0].description
        : InvoiceProvider.itemPrefix;
    _totalAmountController.text =
        _provider.items.isNotEmpty && _provider.items[0].price > 0
        ? NumberFormat('#,##0.##', 'en_US').format(_provider.items[0].price)
        : '';
    _updateDateController();

    _lastCurrency = _provider.selectedCurrency;
    _lastIsGenerating = _provider.isGenerating;
    _lastDate = _provider.date;

    // Listen for updates
    _provider.addListener(_onProviderUpdate);
  }

  void _onProviderUpdate() {
    if (!mounted) return;

    bool controllersUpdated = false;

    if (!_invoiceNumberFocusNode.hasPrimaryFocus &&
        _invoiceNumberController.text != _provider.invoiceNumber) {
      _invoiceNumberController.text = _provider.invoiceNumber;
      controllersUpdated = true;
    }
    if (!_descriptionFocusNode.hasPrimaryFocus &&
        _descriptionController.text != _provider.description) {
      // For the description field, be extra careful as it has its own logic
      _descriptionController.text = _provider.description;
      controllersUpdated = true;
    }
    final formattedPrice = _provider.total > 0
        ? NumberFormat('#,##0.##', 'en_US').format(_provider.total)
        : '';
    if (!_totalAmountFocusNode.hasPrimaryFocus &&
        _totalAmountController.text != formattedPrice) {
      _totalAmountController.text = formattedPrice;
      controllersUpdated = true;
    }

    final bool currencyChanged = _lastCurrency != _provider.selectedCurrency;
    final bool isGeneratingChanged =
        _lastIsGenerating != _provider.isGenerating;
    final bool dateChanged = _lastDate != _provider.date;

    if (currencyChanged || isGeneratingChanged || dateChanged) {
      setState(() {
        _lastCurrency = _provider.selectedCurrency;
        _lastIsGenerating = _provider.isGenerating;
        _lastDate = _provider.date;
        _updateDateController();
      });
    } else if (controllersUpdated && !FocusScope.of(context).hasFocus) {
      setState(() {});
    }
  }

  void _updateDateController() {
    final date = _provider.date;
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    if (_dateController.text != formattedDate) {
      _dateController.text = formattedDate;
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderUpdate);
    _invoiceNumberController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _totalAmountController.dispose();

    _invoiceNumberFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _totalAmountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elada Invoice'), centerTitle: true),
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
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: InvoicePreview(testing: widget.testing),
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
    final provider = context.read<InvoiceProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ChangeNotifierProvider.value(
        value: provider,
        child: DraggableScrollableSheet(
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
                    Expanded(
                      child: Text(
                        'Invoice Preview',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: InvoicePreview(testing: widget.testing),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final provider = _provider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Image.asset(
          'assets/app_icon_new.png',
          height: 80,
        ),
        const SizedBox(height: 8),
        Text(
          'Generate New Invoice',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _dateController,
                label: 'Invoice Date',
                onChanged: (_) {},
                readOnly: true,
                onTap: () => _selectDate(context),
                prefixIcon: const Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInputField(
                controller: _invoiceNumberController,
                focusNode: _invoiceNumberFocusNode,
                label: 'Invoice Number',
                onChanged: (val) =>
                    context.read<InvoiceProvider>().updateInvoiceNumber(val),
                keyboardType: TextInputType.number,
                updateOnType: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildInputField(
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          label: 'Item Description',
          onChanged: (val) => provider.updateItemDescription(0, val),
          maxLines: 2,
          updateOnType: false,
          inputFormatters: [
            PrefixTextInputFormatter(InvoiceProvider.itemPrefix),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Currency',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: '€', label: Text('€')),
                        ButtonSegment(value: '\$', label: Text('\$')),
                        ButtonSegment(value: '£', label: Text('£')),
                      ],
                      selected: {provider.selectedCurrency},
                      onSelectionChanged: (Set<String> newSelection) {
                        context.read<InvoiceProvider>().updateCurrency(
                          newSelection.first,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _buildInputField(
                controller: _totalAmountController,
                focusNode: _totalAmountFocusNode,
                label: 'Total Amount',
                onChanged: (val) {
                  final doubleValue =
                      double.tryParse(val.replaceAll(',', '')) ?? 0.0;
                  provider.updateItemPrice(0, doubleValue);
                },
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [ThousandsFormatter()],
                updateOnType: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(77),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: provider.isGenerating
                      ? null
                      : () => _generatePdf(context),
                  icon: provider.isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf),
                  label: Text(
                    provider.isGenerating ? 'Generating...' : 'Generate PDF',
                  ),
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
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _clearForm(context),
          icon: const Icon(Icons.clear_all),
          label: const Text('Clear Form'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  void _clearForm(BuildContext context) {
    final provider = context.read<InvoiceProvider>();
    provider.updateDate(DateTime.now());
    provider.clearItems();

    // Increment the invoice number
    provider.incrementInvoiceNumber();

    _descriptionController.text = InvoiceProvider.itemPrefix;
    _totalAmountController.clear();
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
      // Manually trigger update to ensure UI reflects change immediately
      setState(() {
        _updateDateController();
      });
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

    // Validation
    if (provider.invoiceNumber.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an Invoice Number'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // 1. Generate and Save PDF
      final savedPath = await provider.generateAndSaveInvoice();

      // 2. Success message
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('OK'),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('Invoice saved to: $savedPath')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e, st) {
      print('=== PDF GENERATION ERROR ===');
      print(e);
      print(st);
      print('============================');
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
    Key? key,
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefixText,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? prefixIcon,
    FocusNode? focusNode,
    List<TextInputFormatter>? inputFormatters,
    bool updateOnType = false,
  }) {
    return Focus(
      canRequestFocus: !(readOnly && onTap == null),
      descendantsAreFocusable: !(readOnly && onTap == null),
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          onChanged(controller.text);
        }
      },
      child: TextField(
        key: key,
        controller: controller,
        onChanged: updateOnType ? onChanged : null,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        focusNode: focusNode,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
          prefixText: prefixText,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withAlpha(77), // ~0.3 opacity
        ),
      ),
    );
  }
}

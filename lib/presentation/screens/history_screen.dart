import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';
import 'package:elada/data/models/invoice.dart';
import 'package:elada/presentation/utils/currency_utils.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  final VoidCallback? onSelectInvoice;

  const HistoryScreen({super.key, this.onSelectInvoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice History'),
        centerTitle: true,
        actions: [
          Consumer<InvoiceProvider>(
            builder: (context, provider, child) {
              if (provider.history.isEmpty && provider.drafts.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => _confirmClearAll(context, provider),
                tooltip: 'Clear All History',
                color: Theme.of(context).colorScheme.error,
              );
            },
          ),
        ],
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, child) {
          final history = provider.history;
          final drafts = provider.drafts;

          if (history.isEmpty && drafts.isEmpty) {
            return _buildEmptyState(context);
          }

          return RepaintBoundary(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (drafts.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Drafts'),
                  ...drafts.asMap().entries.map((entry) {
                    return _buildAnimatedItem(
                      index: entry.key,
                      child: _buildDraftItem(
                        context,
                        provider,
                        entry.value,
                        entry.key,
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
                if (history.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Generated Invoices'),
                  ...history.asMap().entries.map((entry) {
                    return _buildAnimatedItem(
                      index: drafts.length + entry.key,
                      child: _buildHistoryItem(
                        context,
                        provider,
                        entry.value,
                        entry.key,
                      ),
                    );
                  }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 500)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Your generated invoices and drafts will appear here.'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    InvoiceProvider provider,
    Invoice invoice,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          provider.loadInvoice(invoice);
          onSelectInvoice?.call();
        },
        title: Text(
          (invoice.items != null && invoice.items!.isNotEmpty)
              ? invoice.items!.first.description
              : invoice.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#${invoice.invoiceNumber} • ${DateFormat('MMM dd, yyyy').format(invoice.effectiveDate)}',
            ),
            if (invoice.items != null &&
                invoice.items!.isNotEmpty &&
                invoice.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  invoice.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyUtils.formatAmount(invoice.total, invoice.currency),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () =>
                  _confirmDeleteHistory(context, provider, invoice),
              tooltip: 'Delete History Entry',
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftItem(
    BuildContext context,
    InvoiceProvider provider,
    Invoice draft,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.secondary.withAlpha(100),
          width: 0.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          provider.loadInvoice(draft);
          onSelectInvoice?.call();
        },
        title: Text(
          draft.description.isEmpty ? '(No Description)' : draft.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Draft #${draft.invoiceNumber}',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                provider.loadInvoice(draft);
                onSelectInvoice?.call();
              },
              tooltip: 'Edit Draft',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, provider, draft),
              tooltip: 'Delete Draft',
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    InvoiceProvider provider,
    Invoice draft,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Draft'),
        content: const Text('Are you sure you want to delete this draft?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteDraft(draft);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteHistory(
    BuildContext context,
    InvoiceProvider provider,
    Invoice invoice,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete History Entry'),
        content: const Text(
          'Are you sure you want to delete this invoice from history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteHistoryEntry(invoice);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, InvoiceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All'),
        content: const Text(
          'Are you sure you want to delete all history entries and drafts?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAllHistoryAndDrafts();
              Navigator.pop(context);
            },
            child: Text(
              'Clear All',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

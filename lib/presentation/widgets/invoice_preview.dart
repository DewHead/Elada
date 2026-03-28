import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';
import 'package:elada/presentation/providers/invoice_provider.dart';

class InvoicePreview extends StatefulWidget {
  final bool testing;
  const InvoicePreview({super.key, this.testing = false});

  @override
  State<InvoicePreview> createState() => _InvoicePreviewState();
}

class _InvoicePreviewState extends State<InvoicePreview> {
  Uint8List? _lastValidBytes;
  Uint8List? _currentDisplayBytes;
  bool _isNewDocumentLoading = false;
  double _newDocumentOpacity = 0.0;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<InvoiceProvider>();
    final bool bypassViewer =
        Platform.environment.containsKey('FLUTTER_TEST') && !widget.testing;

    return ValueListenableBuilder<bool>(
      valueListenable: provider.isPreviewLoadingNotifier,
      builder: (context, isPreviewLoading, child) {
        return ValueListenableBuilder<Uint8List?>(
          valueListenable: provider.previewBytesNotifier,
          builder: (context, previewBytes, child) {
            if (isPreviewLoading && previewBytes == null && _lastValidBytes == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final displayBytes = previewBytes ?? _lastValidBytes;

            if (displayBytes == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.preview_rounded,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withAlpha(128),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter details to see preview',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Update state when new bytes arrive
            if (previewBytes != null && previewBytes != _currentDisplayBytes) {
              _isNewDocumentLoading = true;
              _newDocumentOpacity = 0.0;
              _currentDisplayBytes = previewBytes;
            }

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Previous valid document (Back buffer)
                  if (_lastValidBytes != null && _lastValidBytes != _currentDisplayBytes)
                    bypassViewer
                        ? const SizedBox.shrink()
                        : SfPdfViewer.memory(
                            _lastValidBytes!,
                            enableDoubleTapZooming:
                                false, // Disable interactions for background
                          ),

                  // Current document (Front buffer)
                  if (_currentDisplayBytes != null)
                    AnimatedOpacity(
                      opacity: _newDocumentOpacity,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                      child: bypassViewer
                          ? Builder(
                              builder: (context) {
                                // Simulate document load for tests to update state
                                Future.microtask(() {
                                  if (mounted && _newDocumentOpacity == 0.0) {
                                    setState(() {
                                      _newDocumentOpacity = 1.0;
                                      _isNewDocumentLoading = false;
                                      _lastValidBytes = _currentDisplayBytes;
                                    });
                                  }
                                });
                                return const SizedBox.shrink();
                              },
                            )
                          : SfPdfViewer.memory(
                              _currentDisplayBytes!,
                              key: ValueKey(
                                'pdf_viewer_${_currentDisplayBytes!.length}_${_currentDisplayBytes!.hashCode}',
                              ),
                              onDocumentLoaded: (details) {
                                setState(() {
                                  _newDocumentOpacity = 1.0;
                                  _isNewDocumentLoading = false;
                                  _lastValidBytes = _currentDisplayBytes;
                                });
                              },
                              enableDoubleTapZooming: true,
                            ),
                    ),

                  // Loading indicator overlay
                  if (isPreviewLoading || _isNewDocumentLoading)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withAlpha(230),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(51),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

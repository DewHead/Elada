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
  bool _isPreviewLoading = false;

  late InvoiceProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<InvoiceProvider>();
    _currentDisplayBytes = _provider.previewBytes;
    _lastValidBytes = _currentDisplayBytes;
    _isPreviewLoading = _provider.isPreviewLoading;
    
    if (_currentDisplayBytes != null) {
      _newDocumentOpacity = 1.0;
    }

    _provider.previewBytesNotifier.addListener(_onPreviewBytesChanged);
    _provider.isPreviewLoadingNotifier.addListener(_onLoadingChanged);
  }

  @override
  void dispose() {
    _provider.previewBytesNotifier.removeListener(_onPreviewBytesChanged);
    _provider.isPreviewLoadingNotifier.removeListener(_onLoadingChanged);
    super.dispose();
  }

  void _onPreviewBytesChanged() {
    if (!mounted) return;
    final newBytes = _provider.previewBytesNotifier.value;
    
    if (newBytes != null && newBytes != _currentDisplayBytes) {
      setState(() {
        _isNewDocumentLoading = true;
        _newDocumentOpacity = 0.0;
        _currentDisplayBytes = newBytes;
      });
    }
  }

  void _onLoadingChanged() {
    if (!mounted) return;
    setState(() {
      _isPreviewLoading = _provider.isPreviewLoadingNotifier.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool bypassViewer =
        Platform.environment.containsKey('FLUTTER_TEST') && !widget.testing;

    if (_isPreviewLoading && _currentDisplayBytes == null && _lastValidBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final displayBytes = _currentDisplayBytes ?? _lastValidBytes;

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
            IgnorePointer(
              child: bypassViewer
                  ? const SizedBox.shrink()
                  : SfPdfViewer.memory(
                      _lastValidBytes!,
                      enableDoubleTapZooming: false,
                    ),
            ),

          // Current document (Front buffer)
          if (_currentDisplayBytes != null)
            AnimatedOpacity(
              opacity: _newDocumentOpacity,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: bypassViewer
                  ? Builder(
                      builder: (context) {
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
                      // Prevent stealing focus
                      canShowPaginationDialog: false,
                      canShowScrollHead: false,
                      canShowScrollStatus: false,
                    ),
            ),

          // Loading indicator overlay
          if (_isPreviewLoading || _isNewDocumentLoading)
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
  }
}

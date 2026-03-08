import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/payment_handler.dart';
import '../../../../core/services/api_service.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/patrika_issue.dart';

class PatrikaViewerPage extends ConsumerStatefulWidget {
  final PatrikaIssue issue;

  const PatrikaViewerPage({
    super.key,
    required this.issue,
  });

  @override
  ConsumerState<PatrikaViewerPage> createState() => _PatrikaViewerPageState();
}

class _PatrikaViewerPageState extends ConsumerState<PatrikaViewerPage> {
  bool _hasPurchased = false;
  PdfController? _pdfController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPurchaseStatus();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _checkPurchaseStatus() async {
    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;
      if (userId == null) {
        setState(() {
          _hasPurchased = false;
        });
        _loadPdf();
        return;
      }

      final purchases = await ApiService.getPatrikaPurchases(userId);
      final exists = purchases.contains(widget.issue.id);
      setState(() {
        _hasPurchased = exists;
      });
      
      _loadPdf();
    } catch (e) {
      setState(() {
        _hasPurchased = false;
      });
      _loadPdf();
    }
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await http.get(Uri.parse(widget.issue.pdfUrl));
      
      if (response.statusCode == 200) {
        _pdfController = PdfController(
          document: PdfDocument.openData(response.bodyBytes),
        );
        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load PDF: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading PDF: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading PDF: $e')),
        );
      }
    }
  }

  void _showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Patrika'),
        content: Text(
          'Purchase this issue for ₹${widget.issue.price.toInt()} to read the full content.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              PaymentHandler.handlePatrikaPayment(
                context,
                widget.issue.id,
                widget.issue.price,
              );
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.issue.title),
        actions: [
          if (!_hasPurchased)
            IconButton(
              icon: const Icon(Icons.payment),
              onPressed: _showPurchaseDialog,
              tooltip: 'Purchase',
            ),
        ],
      ),
      body: Column(
        children: [
          if (!_hasPurchased)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade50,
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Preview: First ${AppConstants.patrikaPreviewPages} pages. Purchase to read full content.',
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadPdf,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _pdfController != null
                        ? PdfView(
                            controller: _pdfController!,
                          )
                        : const Center(child: Text('No PDF loaded')),
          ),
        ],
      ),
    );
  }
}

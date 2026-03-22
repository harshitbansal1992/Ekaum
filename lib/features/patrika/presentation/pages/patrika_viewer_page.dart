import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/payment_handler.dart';
import '../../../../core/services/api_service.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
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
  PdfControllerPinch? _pdfController;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 0;
  final TextEditingController _pageNumberController = TextEditingController();
  Timer? _purchasePollingTimer;
  bool _isCheckingPurchase = false;
  bool _awaitingPurchaseVerification = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    _checkPurchaseStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    _purchasePollingTimer?.cancel();
    _pageNumberController.dispose();
    _pdfController?.dispose();
    super.dispose();
  }

  late final WidgetsBindingObserver _lifecycleObserver = _PatrikaLifecycleObserver(
    onResume: () {
      _checkPurchaseStatus(silent: true, reloadPdf: false);
    },
  );

  int get _maxAllowedPage {
    if (_totalPages == 0) return 0;
    if (_hasPurchased) return _totalPages;
    return _totalPages < AppConstants.patrikaPreviewPages
        ? _totalPages
        : AppConstants.patrikaPreviewPages;
  }

  void _showTopAlert(String message, {bool isError = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..clearMaterialBanners()
      ..showMaterialBanner(
        MaterialBanner(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade50 : Colors.blue.shade50,
          contentTextStyle: TextStyle(
            color: isError ? Colors.red.shade900 : Colors.blue.shade900,
            fontWeight: FontWeight.w600,
          ),
          actions: [
            TextButton(
              onPressed: messenger.hideCurrentMaterialBanner,
              child: const Text('OK'),
            ),
          ],
        ),
      );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        messenger.hideCurrentMaterialBanner();
      }
    });
  }

  Future<void> _checkPurchaseStatus({bool silent = false, bool reloadPdf = true}) async {
    if (_isCheckingPurchase) return;
    _isCheckingPurchase = true;
    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;
      if (userId == null) {
        setState(() {
          _hasPurchased = false;
        });
        _stopPurchaseAutoRefresh();
        if (reloadPdf) {
          await _loadPdf();
        }
        return;
      }

      final purchases = await ApiService.getPatrikaPurchases(userId);
      final exists = purchases.contains(widget.issue.id);
      final unlockedNow = exists && !_hasPurchased;
      setState(() {
        _hasPurchased = exists;
      });

      if (exists) {
        _stopPurchaseAutoRefresh();
        _awaitingPurchaseVerification = false;
      } else {
        _startPurchaseAutoRefresh();
      }

      if (unlockedNow && _awaitingPurchaseVerification && mounted && !silent) {
        _showTopAlert('Purchase verified. Full Patrika unlocked.');
      }

      if (reloadPdf || unlockedNow) {
        await _loadPdf();
      }
    } catch (e) {
      setState(() {
        _hasPurchased = false;
      });
      if (reloadPdf) {
        await _loadPdf();
      }
    } finally {
      _isCheckingPurchase = false;
    }
  }

  void _startPurchaseAutoRefresh() {
    if (_purchasePollingTimer != null) return;

    _purchasePollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _hasPurchased) {
        _stopPurchaseAutoRefresh();
        return;
      }
      _checkPurchaseStatus(silent: true, reloadPdf: false);
    });
  }

  void _stopPurchaseAutoRefresh() {
    _purchasePollingTimer?.cancel();
    _purchasePollingTimer = null;
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await http.get(Uri.parse(widget.issue.pdfUrl));
      
      if (response.statusCode == 200) {
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openData(response.bodyBytes),
        );
        setState(() {
          _isLoading = false;
          _currentPage = 1;
          _totalPages = 0;
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
        _showTopAlert('Error loading PDF: $e', isError: true);
      }
    }
  }

  Future<void> _goToPage(int page) async {
    final controller = _pdfController;
    if (controller == null || _maxAllowedPage == 0) return;

    if (page < 1 || page > _maxAllowedPage) {
      if (mounted) {
        _showTopAlert('Enter a page between 1 and $_maxAllowedPage', isError: true);
      }
      _pageNumberController.text = _currentPage.toString();
      return;
    }

    await controller.animateToPage(
      pageNumber: page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );

    if (mounted) {
      setState(() {
        _currentPage = page;
      });
      _pageNumberController.text = page.toString();
    }
  }

  Future<void> _goToNextPage() async {
    if (_currentPage >= _maxAllowedPage) {
      if (!_hasPurchased && mounted) {
        _showTopAlert('Purchase to read more pages.');
      }
      return;
    }
    await _goToPage(_currentPage + 1);
  }

  Future<void> _goToPreviousPage() async {
    if (_currentPage <= 1) return;
    await _goToPage(_currentPage - 1);
  }

  Widget _buildNavigationBar() {
    final maxAllowed = _maxAllowedPage;
    final canGoPrev = _currentPage > 1;
    final canGoNext = maxAllowed > 0 && _currentPage < maxAllowed;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: canGoPrev ? _goToPreviousPage : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous page',
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Page '),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: _pageNumberController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      final page = int.tryParse(value.trim());
                      if (page != null) {
                        _goToPage(page);
                      } else {
                        _pageNumberController.text = _currentPage.toString();
                      }
                    },
                  ),
                ),
                Text(' / $maxAllowed'),
              ],
            ),
          ),
          IconButton(
            onPressed: canGoNext ? _goToNextPage : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next page',
          ),
        ],
      ),
    );
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
            onPressed: () async {
              Navigator.pop(context);
              await PaymentHandler.handlePatrikaPayment(
                context,
                widget.issue.id,
                widget.issue.price,
              );
              _awaitingPurchaseVerification = true;
              _startPurchaseAutoRefresh();
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
          if (!_isLoading && _errorMessage == null && _pdfController != null)
            _buildNavigationBar(),
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
                        ? PdfViewPinch(
                            controller: _pdfController!,
                            onDocumentLoaded: (document) {
                              if (!mounted) return;
                              final maxAllowed = _hasPurchased
                                  ? document.pagesCount
                                  : (document.pagesCount < AppConstants.patrikaPreviewPages
                                      ? document.pagesCount
                                      : AppConstants.patrikaPreviewPages);

                              setState(() {
                                _totalPages = document.pagesCount;
                                _currentPage = 1;
                              });
                              _pageNumberController.text = '1';

                              if (!_hasPurchased && document.pagesCount > maxAllowed) {
                                _showTopAlert(
                                  'Preview limited to first $maxAllowed pages. Purchase for full access.',
                                );
                              }
                            },
                            onPageChanged: (page) {
                              if (!mounted) return;

                              final maxAllowed = _maxAllowedPage;
                              if (!_hasPurchased && maxAllowed > 0 && page > maxAllowed) {
                                _goToPage(maxAllowed);
                                _showTopAlert('Purchase to access more pages.');
                                return;
                              }

                              setState(() {
                                _currentPage = page;
                              });
                              _pageNumberController.text = page.toString();
                            },
                          )
                        : const Center(child: Text('No PDF loaded')),
          ),
        ],
      ),
    );
  }
}

class _PatrikaLifecycleObserver extends WidgetsBindingObserver {
  _PatrikaLifecycleObserver({required this.onResume});

  final VoidCallback onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}

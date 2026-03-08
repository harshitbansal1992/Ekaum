import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';

// Conditional imports - only import webview on non-web platforms
import 'package:webview_flutter/webview_flutter.dart' if (dart.library.html) 'package:flutter/material.dart';

class PoojaItemsPage extends StatefulWidget {
  const PoojaItemsPage({super.key});

  @override
  State<PoojaItemsPage> createState() => _PoojaItemsPageState();
}

class _PoojaItemsPageState extends State<PoojaItemsPage> {
  dynamic _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // On mobile/desktop, try to use WebView if available
      try {
        // ignore: undefined_class
        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() => _isLoading = true);
              },
              onPageFinished: (String url) {
                setState(() => _isLoading = false);
              },
              onWebResourceError: (WebResourceError error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${error.description}')),
                );
              },
            ),
          )
          ..loadRequest(Uri.parse(AppConstants.poojaItemsUrl));
      } catch (e) {
        // WebView not available on this platform, will use browser fallback
        debugPrint('WebView not available: $e');
        _controller = null;
      }
    }
  }

  Future<void> _openInBrowser() async {
    final url = Uri.parse(AppConstants.poojaItemsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Try to use WebView if available (mobile platforms)
    if (_controller != null && !kIsWeb) {
      try {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pooja Items'),
          ),
          body: Stack(
            children: [
              // ignore: undefined_class
              WebViewWidget(controller: _controller as WebViewController),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        );
      } catch (e) {
        // WebView not available, fall through to browser fallback
        debugPrint('WebViewWidget not available: $e');
      }
    }

    // Fallback for web and Windows desktop - open in browser
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pooja Items'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart, size: 64),
            const SizedBox(height: 16),
            const Text('Pooja Items'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Pooja Items Website'),
            ),
          ],
        ),
      ),
    );
  }
}


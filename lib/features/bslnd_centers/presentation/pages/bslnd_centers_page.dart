import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';

import 'package:webview_flutter/webview_flutter.dart' if (dart.library.html) 'package:flutter/material.dart';

/// BSLND Centers from https://mahabrahmrishi.com/bslnd-centers/
class BslndCentersPage extends StatefulWidget {
  const BslndCentersPage({super.key});

  @override
  State<BslndCentersPage> createState() => _BslndCentersPageState();
}

class _BslndCentersPageState extends State<BslndCentersPage> {
  dynamic _controller;
  bool _isLoading = false;
  static const String _centersUrl = 'https://mahabrahmrishi.com/bslnd-centers/';

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      try {
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
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${error.description}')),
                  );
                }
              },
            ),
          )
          ..loadRequest(Uri.parse(_centersUrl));
      } catch (e) {
        debugPrint('WebView not available: $e');
        _controller = null;
      }
    }
  }

  Future<void> _openInBrowser() async {
    final url = Uri.parse(_centersUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null && !kIsWeb) {
      try {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.bslndCenters),
            actions: [
              IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: _openInBrowser,
              ),
            ],
          ),
          body: Stack(
            children: [
              WebViewWidget(controller: _controller as WebViewController),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        );
      } catch (e) {
        debugPrint('WebViewWidget not available: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.bslndCenters),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.place_outlined, size: 64),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.bslndCenters),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_new),
              label: Text(AppLocalizations.of(context)!.openInBrowser),
            ),
          ],
        ),
      ),
    );
  }
}

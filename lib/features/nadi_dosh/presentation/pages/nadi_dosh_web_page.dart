import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart' if (dart.library.html) 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class NadiDoshWebPage extends StatefulWidget {
  const NadiDoshWebPage({super.key});

  @override
  State<NadiDoshWebPage> createState() => _NadiDoshWebPageState();
}

class _NadiDoshWebPageState extends State<NadiDoshWebPage> {
  dynamic _controller;
  bool _isLoading = false;
  static const String _nadiDoshUrl = 'https://nadidosh.com/';

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      try {
        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) => setState(() => _isLoading = true),
              onPageFinished: (_) => setState(() => _isLoading = false),
              onWebResourceError: (WebResourceError error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${error.description}')),
                  );
                }
              },
            ),
          )
          ..loadRequest(Uri.parse(_nadiDoshUrl));
      } catch (e) {
        debugPrint('WebView not available: $e');
        _controller = null;
      }
    }
  }

  Future<void> _openInBrowser() async {
    final url = Uri.parse(_nadiDoshUrl);
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
    final l10n = AppLocalizations.of(context)!;

    if (_controller != null && !kIsWeb) {
      try {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.nadiDosh),
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
              if (_isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        );
      } catch (e) {
        debugPrint('WebViewWidget not available: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.nadiDosh)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calculate_outlined, size: 64),
            const SizedBox(height: 16),
            Text(l10n.nadiDosh),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.openInBrowser),
            ),
          ],
        ),
      ),
    );
  }
}

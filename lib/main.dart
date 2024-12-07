import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NovanPDFApp extends StatelessWidget {
  const NovanPDFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovanPDF',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NovanPDFWebApp(),
    );
  }
}

class NovanPDFWebApp extends StatefulWidget {
  const NovanPDFWebApp({super.key});

  @override
  State<NovanPDFWebApp> createState() => _NovanPDFWebAppState();
}

class _NovanPDFWebAppState extends State<NovanPDFWebApp> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            final canGoBack = await _webViewController.canGoBack();
            final canGoForward = await _webViewController.canGoForward();
            
            setState(() {
              _isLoading = false;
              _canGoBack = canGoBack;
              _canGoForward = canGoForward;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            _showErrorMessage('Gagal memuat halaman: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..enableZoom(true)
      ..setBackgroundColor(Colors.white)
      ..loadRequest(Uri.parse('https://novan.tolopani.net/'));
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _refreshPage() {
    _webViewController.reload();
  }

  void _goBack() {
    _webViewController.goBack();
  }

  void _goForward() {
    _webViewController.goForward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NovanPDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPage,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _canGoBack ? _goBack : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _canGoForward ? _goForward : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _webViewController,
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const NovanPDFApp());
}
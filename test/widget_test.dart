import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MockWebViewController extends Mock implements WebViewController {}

class TolopaniWebView extends StatefulWidget {
  final String initialUrl;

  const TolopaniWebView({
    super.key,
    this.initialUrl = 'https://novan.tolopani.net/',
  });

  @override
  TolopaniWebViewState createState() => TolopaniWebViewState();
}

class TolopaniWebViewState extends State<TolopaniWebView> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  void _refreshPage() {
    _webViewController.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novan PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPage,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _webViewController,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class TolopaniApp extends StatelessWidget {
  const TolopaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Novan PDF',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TolopaniWebView(),
    );
  }
}

void main() {
  setUp(() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  });

  testWidgets('TolopaniWebView renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TolopaniWebView()));

    expect(find.byType(TolopaniWebView), findsOneWidget);
    expect(find.text('Novan PDF'), findsOneWidget);
  });

  testWidgets('WebView loads initial page', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TolopaniWebView()));

    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(WebViewWidget), findsOneWidget);
  });

  testWidgets('Refresh button exists', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TolopaniWebView()));

    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}

void debugPrint(String message) {
  Logger('TestLogger').info(message);
}
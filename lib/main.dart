import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

// Splash Screen (1 seconds)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const WebViewApp()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 150), // company logo
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// WebView with Custom Error Screen
class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late WebViewController _controller;
  bool isLoading = true;
  bool hasError = false;
  String initialUrl = 'https://staging.astratmutual.com/login';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }




  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
              hasError = false;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });

           
          },
          onWebResourceError: (error) {
            setState(() {
              hasError = true;
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl));
  }

  void _retry() {
    setState(() {
      hasError = false; // 🔥 Pehle error hatao
      isLoading = true; // 🔥 Loading indicator dikhao
    });

    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Stack(
          children: [
            if (!hasError &&
                !isLoading) // 🔥 Jab tak load ho raha hai tab tak WebView na dikhao
              WebViewWidget(controller: _controller),
            if (isLoading)
              const Center(
                  child: CircularProgressIndicator(color: Color.fromARGB(255, 0, 102, 255))),
            if (hasError) NoInternetScreen(onRetry: _retry),
          ],
        ),
      ),
    );
  }
}

// Custom No Internet Screen
class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),//
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/prof.jpg', width: 250), // Custom Error Image
              const SizedBox(height: 20),
              const Text(
                "No Internet Connection",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "You're offline! Please reconnect to access your portfolio.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    const Text("Reload", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


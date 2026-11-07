import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../app/theme.dart';

class PolicyWebViewScreen extends StatefulWidget {
  const PolicyWebViewScreen({required this.title, required this.url, super.key});
  final String title;
  final String url;
  @override
  State<PolicyWebViewScreen> createState() => _PolicyWebViewScreenState();
}

class _PolicyWebViewScreenState extends State<PolicyWebViewScreen> {
  late final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(NavigationDelegate(onPageStarted: (_) => setState(() {})))
    ..loadRequest(Uri.parse(widget.url));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.white,
    appBar: AppBar(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: TextButton(onPressed: () => Navigator.pop(context), child: const Text('완료')),
      title: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    ),
    body: WebViewWidget(controller: _controller),
  );
}

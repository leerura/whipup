import 'package:flutter/material.dart';

class WhipupApp extends StatelessWidget {
  const WhipupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whipup',
      theme: ThemeData(useMaterial3: true),
      home: const SizedBox.shrink(),
    );
  }
}

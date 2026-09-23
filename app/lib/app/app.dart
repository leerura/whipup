import 'package:flutter/material.dart';

import '../features/auth/presentation/onboarding_flow.dart';
import 'theme.dart';

class WhipupApp extends StatelessWidget {
  const WhipupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whipup',
      theme: AppTheme.light,
      home: const OnboardingFlow(),
    );
  }
}

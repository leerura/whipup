import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Shown when the account could not be prepared at start-up (offline, server
/// down). The saved account is kept, so retrying is always safe.
class ConnectionErrorScreen extends StatelessWidget {
  const ConnectionErrorScreen({
    required this.isRetrying,
    required this.onRetry,
    super.key,
  });

  final bool isRetrying;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '서버에 연결할 수 없어요',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '네트워크를 확인하고 다시 시도해 주세요',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: isRetrying ? null : onRetry,
                  child: Text(isRetrying ? '연결 중...' : '다시 시도'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

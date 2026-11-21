import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/config/app_config.dart';
import '../../recipe/presentation/policy_webview_screen.dart';
import 'account_deletion_screen.dart';

/// Settings used by the App Store submission flow.
///
/// The policy URLs default to the published Notion pages and remain injectable
/// for tests or a future hosting change.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.onBack,
    required this.onDeleteAccount,
    required this.onAccountDeleted,
    this.privacyPolicyUrl = AppConfig.privacyPolicyUrl,
    this.termsUrl = AppConfig.termsUrl,
    this.supportUrl = AppConfig.supportUrl,
    super.key,
  });

  final VoidCallback onBack;
  final Future<void> Function() onDeleteAccount;
  final VoidCallback onAccountDeleted;
  final String? privacyPolicyUrl;
  final String? termsUrl;
  final String? supportUrl;

  void _openPolicy(BuildContext context, String title, String? url) {
    if (url == null || url.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$title 링크를 준비 중이에요.')));
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PolicyWebViewScreen(title: title, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(onPressed: onBack),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text('설정', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 40),
            const _SettingsSectionLabel('약관 및 정책'),
            _SettingsRow(
              title: '개인정보처리방침',
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () => _openPolicy(context, '개인정보처리방침', privacyPolicyUrl),
            ),
            _SettingsRow(
              title: '서비스 이용약관',
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () => _openPolicy(context, '서비스 이용약관', termsUrl),
            ),
            _SettingsRow(
              title: '지원 및 문의',
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () => _openPolicy(context, '지원 및 문의', supportUrl),
            ),
            const SizedBox(height: 40),
            const _SettingsSectionLabel('계정'),
            _SettingsRow(
              title: '계정 삭제',
              titleColor: const Color(0xFFFF3B30),
              trailing: const Icon(Icons.chevron_right_rounded, size: 22),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => AccountDeletionScreen(
                    onDeleteAccount: onDeleteAccount,
                    onDeleted: onAccountDeleted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionLabel extends StatelessWidget {
  const _SettingsSectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: Theme.of(context).textTheme.labelSmall),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.onTap,
    this.trailing,
    this.titleColor,
  });
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? titleColor;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 56,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF2F2F7))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: titleColor ?? AppColors.textPrimary),
            ),
          ),
          if (trailing != null)
            IconTheme(
              data: const IconThemeData(color: AppColors.textMuted),
              child: trailing!,
            ),
        ],
      ),
    ),
  );
}

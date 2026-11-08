import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme.dart';
import '../../../core/config/app_config.dart';

class TermsConsentScreen extends StatefulWidget {
  const TermsConsentScreen({required this.onAccepted, super.key});

  final Future<void> Function() onAccepted;

  @override
  State<TermsConsentScreen> createState() => _TermsConsentScreenState();
}

class _TermsConsentScreenState extends State<TermsConsentScreen> {
  bool _terms = false;
  bool _privacy = false;
  bool _age = false;
  bool _isSubmitting = false;

  bool get _allSelected => _terms && _privacy && _age;

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('문서를 열 수 없어요.')));
    }
  }

  Future<void> _submit() async {
    if (!_allSelected || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onAccepted();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('동의를 저장하지 못했어요. 다시 시도해 주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                children: [
                  Text(
                    'whippy를 시작하기 전에\n확인해 주세요',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontSize: 20, height: 1.35),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '서비스를 이용하려면 아래 내용에 동의가 필요해요.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Material(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                    child: CheckboxListTile(
                      value: _allSelected,
                      onChanged: (value) {
                        final selected = value ?? false;
                        setState(() => _terms = _privacy = _age = selected);
                      },
                      title: const Text(
                        '모두 동의',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ConsentRow(
                    value: _terms,
                    title: '서비스 이용약관',
                    onChanged: (value) =>
                        setState(() => _terms = value ?? false),
                    onOpen: () => _open(AppConfig.termsUrl),
                  ),
                  _ConsentRow(
                    value: _privacy,
                    title: '개인정보 수집·이용',
                    onChanged: (value) =>
                        setState(() => _privacy = value ?? false),
                    onOpen: () => _open(AppConfig.privacyPolicyUrl),
                  ),
                  _ConsentRow(
                    value: _age,
                    title: '만 14세 이상입니다',
                    onChanged: (value) => setState(() => _age = value ?? false),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _allSelected && !_isSubmitting
                            ? _submit
                            : null,
                        style: FilledButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.disabled,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: Text(_isSubmitting ? '저장 중...' : '동의하고 시작하기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.value,
    required this.title,
    required this.onChanged,
    this.onOpen,
  });

  final bool value;
  final String title;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      side: const BorderSide(color: AppColors.border),
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text.rich(
        TextSpan(
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          children: [
            const TextSpan(
              text: '(필수)  ',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: title),
          ],
        ),
      ),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      secondary: onOpen == null
          ? null
          : TextButton.icon(
              onPressed: onOpen,
              icon: const SizedBox.shrink(),
              label: const Text(
                '보기 ›',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }
}

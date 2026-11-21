import 'package:flutter/material.dart';

import '../../../app/theme.dart';

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({
    required this.onDeleteAccount,
    required this.onDeleted,
    super.key,
  });
  final Future<void> Function() onDeleteAccount;
  final VoidCallback onDeleted;
  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  bool _isDeleting = false;
  bool _completed = false;

  Future<void> _delete() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text('계정을 삭제할까요?', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('삭제한 정보는 복구할 수 없어요.'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                  ),
                  child: const Text('계정 삭제'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const SizedBox(
                  width: double.infinity,
                  child: Center(child: Text('취소')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isDeleting = true);
    try {
      await widget.onDeleteAccount();
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _completed = true;
      });
    } catch (error) {
      debugPrint('[Account deletion] UI flow failed: $error');
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계정을 삭제하지 못했어요. 다시 시도해 주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.white,
    appBar: AppBar(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: const BackButton(),
    ),
    body: _completed
        ? _CompletionView(
            onDone: () {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) navigator.pop();
              widget.onDeleted();
            },
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              Text(
                '계정을 삭제하기 전에\n확인해 주세요',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const Text('삭제하면 아래 정보가 모두 사라지고\n되돌릴 수 없어요.'),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '삭제되는 정보',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text('•  내 재료함에 등록한 재료'),
                    SizedBox(height: 12),
                    Text('•  온보딩 완료 상태'),
                    SizedBox(height: 12),
                    Text('•  약관 동의 기록'),
                  ],
                ),
              ),
              const SizedBox(height: 300),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _isDeleting ? null : _delete,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                  ),
                  child: _isDeleting
                      ? const CircularProgressIndicator()
                      : const Text('계정 삭제하기'),
                ),
              ),
            ],
          ),
  );
}

class _CompletionView extends StatelessWidget {
  const _CompletionView({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 220, 20, 40),
    child: Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.surfaceSubtle,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        Text('계정이 삭제됐어요', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Whippy를 이용해 주셔서 감사해요.'),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(onPressed: onDone, child: const Text('처음으로')),
        ),
      ],
    ),
  );
}

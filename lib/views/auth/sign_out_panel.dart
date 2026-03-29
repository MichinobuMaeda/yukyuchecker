import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/authentication.dart';

class SignOutPanel extends HookConsumerWidget {
  const SignOutPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confirm = useState(false);

    Future<void> handleSubmit() async {
      final result = await signOut();
      result.match(
        (error) => debugPrint('Error signing out: $error'),
        (_) => debugPrint('Signed out successfully'),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.0,
          children: confirm.value
              ? [
                  Text('本当にログアウトしますか？'),
                  Wrap(
                    direction: Axis.horizontal,
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: [
                      OutlinedButton(
                        onPressed: () => confirm.value = false,
                        child: Text("キャンセル"),
                      ),
                      FilledButton(
                        onPressed: () => handleSubmit(),
                        style: FilledButton.styleFrom(
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text("ログアウト"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]
              : [
                  Text('通常の利用方法でログアウトは必要ありません。'),
                  OutlinedButton(
                    onPressed: () => confirm.value = true,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text("ログアウト"),
                      ],
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}

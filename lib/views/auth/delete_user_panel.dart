import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/models.dart';
import '../../services/authentication.dart';

const _aboutAccountDeletion = 'アカウントを削除するとすべてのデータが失われ、元に戻すことができません。';
const _confirmAccountDeletion = '本当にアカウントを削除しますか？';

class DeleteUserPanel extends HookConsumerWidget {
  const DeleteUserPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confirm = useState(false);

    Future<void> handleSubmit() async {
      {
        final uid = ref.read(uidProvider);
        if (uid == null) {
          debugPrint('No authenticated user.');
          return;
        }
        final result = await deleteUserData(uid);
        result.match(
          (error) => debugPrint('Error deleting user data: $error'),
          (_) => debugPrint('User data deleted successfully'),
        );
      }
      {
        final result = await deleteUser();
        result.match(
          (error) => debugPrint('Error deleting user: $error'),
          (_) => debugPrint('User deleted successfully'),
        );
      }
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
                  Text(_aboutAccountDeletion),
                  Text(_confirmAccountDeletion),
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
                        onPressed: () {
                          confirm.value = false;
                          showBottomSheet(
                            context: context,
                            builder: (context) => _ConfirmationSheet(
                              onCancel: () => Navigator.pop(context),
                              onConfirm: () {
                                Navigator.pop(context);
                                handleSubmit();
                              },
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text("アカウント削除"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]
              : [
                  Text(_aboutAccountDeletion),
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
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text("アカウント削除"),
                      ],
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}

class _ConfirmationSheet extends StatelessWidget {
  const _ConfirmationSheet({required this.onCancel, required this.onConfirm});

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        spacing: 16.0,
        children: [
          Text(_aboutAccountDeletion),
          Divider(),
          Text(_confirmAccountDeletion),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              OutlinedButton(onPressed: onCancel, child: Text('キャンセル')),
              FilledButton(
                onPressed: onConfirm,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 8),
                    Text('削除する'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../config/firebase.dart';
import '../../services/helpers.dart';
import '../../services/validators.dart';
import '../../services/authentication.dart';

class ResetPasswordPanel extends HookConsumerWidget {
  const ResetPasswordPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.read(snackBarMessageProvider.notifier);
    final authUser = ref.watch(authUserProvider).value;
    final email = useTextEditingController(text: authUser?.email ?? '');
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final isFormValid = useState(false);

    Future<void> handleSubmit() async {
      final result = await sendPasswordResetEmail(email.text.trim());
      result.match(
        (error) {
          debugPrint('Error sending password reset email: $error');
          message.show("パスワード設定用のリンクの送信に失敗しました。");
        },
        (_) {
          message.show("パスワード設定用のリンクを送信しました。");
        },
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.0,
          children: <Widget>[
            Text("パスワード設定のためのリンクをEメールで受信する"),
            Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: () {
                isFormValid.value = formKey.currentState?.validate() ?? false;
              },
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16.0,
                runSpacing: 16.0,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 512),
                    child: TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          validateRequiredEmail(value?.trim() ?? ''),
                      decoration: InputDecoration(
                        labelText: "メールアドレス",
                        helperText: "メールアドレスを入力してください",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: validateRequiredEmail(email.text.trim()) == null
                        ? () => handleSubmit()
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send),
                        SizedBox(width: 8),
                        Text("送信"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text("【注意】 $emailFrom からのメールが受信できるようにしてください。"),
          ],
        ),
      ),
    );
  }
}

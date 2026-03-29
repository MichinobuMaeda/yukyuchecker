import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/helpers.dart';
import '../../services/validators.dart';
import '../../services/authentication.dart';
import '../../widgets/password_form_field.dart';

class PasswordReauthenticatePanel extends HookConsumerWidget {
  const PasswordReauthenticatePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.read(snackBarMessageProvider.notifier);
    final authUser = ref.watch(authUserProvider).value;
    final password = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final isFormValid = useState(false);

    if (authUser?.email == null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "ユーザーのメールアドレスが見つからないため、"
            "パスワードによる再認証ができません。",
          ),
        ),
      );
    }

    Future<void> handleSubmit() async {
      message.clear();
      final value = password.text;
      password.value = TextEditingValue.empty;
      final result = await reauthenticateWithPassword(authUser!.email!, value);
      result.match(
        (error) {
          debugPrint('Error reauthenticating with password: $error');
          message.show("再認証に失敗しました。");
        },
        (_) {
          message.show("再認証に成功しました。");
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
            Text("パスワードで再認証する"),
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
                    child: PasswordFormField(
                      controller: password,
                      labelText: "パスワード",
                      helperText: "パスワードを入力してください",
                      validator: (value) =>
                          validateRequiredPassword(value ?? ''),
                    ),
                  ),
                  FilledButton(
                    onPressed: isFormValid.value ? () => handleSubmit() : null,
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
          ],
        ),
      ),
    );
  }
}

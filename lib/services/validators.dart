final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String? validateRequiredEmail(String? value) {
  if (value == null || value.isEmpty) {
    return "メールアドレスを入力してください";
  }

  if (!_emailPattern.hasMatch(value)) {
    return "有効なメールアドレスを入力してください";
  }
  return null;
}

String? validateRequiredPassword(String? value) {
  if (value == null || value.isEmpty) {
    return "パスワードを入力してください";
  }
  return null;
}

String? validateConfirmation(String? original, String? value) {
  if (value == null || value.isEmpty) {
    return "確認のため再度入力してください";
  }
  if (value != original) {
    return "確認の入力内容が一致しません";
  }
  return null;
}

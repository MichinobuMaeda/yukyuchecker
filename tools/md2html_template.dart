String template(String title, String body) {
  return '''<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>
  <link rel="stylesheet" href="main.css">
</head>
<body>
  <main>
    $body
  </main>
</body>
</html>
''';
}

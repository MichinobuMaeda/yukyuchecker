import 'dart:io';
import 'package:markdown/markdown.dart' as md;
import 'md2html_template.dart';

void main() {
  final docsDir = Directory('docs');
  if (!docsDir.existsSync()) {
    stderr.writeln('Error: docs directory not found.');
    exitCode = 1;
    return;
  }

  // Copy CSS file
  try {
    final cssSource = File('tools/md2html.css');
    if (!cssSource.existsSync()) {
      stderr.writeln('Error: tools/md2html.css not found.');
      exitCode = 1;
      return;
    }
    final cssDest = File('docs/main.css');
    cssSource.copySync(cssDest.path);
    stdout.writeln('Copied: ${cssDest.path}');
  } catch (e) {
    stderr.writeln('Error copying CSS file: $e');
    exitCode = 1;
    return;
  }

  // Process Markdown files
  final mdFiles = docsDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.md'))
      .toList();

  if (mdFiles.isEmpty) {
    stderr.writeln('No Markdown files found in docs directory.');
    exitCode = 1;
    return;
  }

  for (final file in mdFiles) {
    try {
      var markdown = file.readAsStringSync();
      // Replace .md links with .html
      markdown = markdown.replaceAll(RegExp(r'\.md(?=[\)\]])'), '.html');
      final html = md.markdownToHtml(markdown);
      final htmlPath = file.path.replaceAll('.md', '.html');
      final htmlContent = template(file.uri.pathSegments.last, html);
      File(htmlPath).writeAsStringSync(htmlContent);
      stdout.writeln('Generated: $htmlPath');
    } catch (e) {
      stderr.writeln('Error processing ${file.path}: $e');
      exitCode = 1;
    }
  }

  // Copy info.md to assets and replace links
  try {
    final infoSource = File('docs/info.md');
    if (infoSource.existsSync()) {
      var infoMarkdown = infoSource.readAsStringSync();
      // Replace local index.md link with external URL
      infoMarkdown = infoMarkdown.replaceAll(
        RegExp(r'./index\.md'),
        'https://pages.michinobu.jp/yukyuchecker/index.html',
      );
      final infoDest = File('assets/info.md');
      infoDest.writeAsStringSync(infoMarkdown);
      stdout.writeln('Copied and processed: ${infoDest.path}');
    }
  } catch (e) {
    stderr.writeln('Error processing info.md: $e');
    exitCode = 1;
  }

  stdout.writeln('✓ All Markdown files converted to HTML');
}

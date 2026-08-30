import 'dart:io';

import 'api_model.dart';
import 'process.dart';

Future<void> main() async {
  final projectRoot = Directory.current.absolute.path;
  await Directory('tool/api').create(recursive: true);
  await runChecked(
      'dart',
      <String>[
        'run',
        'dart_apitool:main',
        'extract',
        '--input',
        projectRoot,
        '--output',
        '$projectRoot/tool/api/current.json',
        '--force-use-flutter',
        '--set-exit-on-missing-export',
      ],
      workingDirectory: 'tool/dart_apitool');
  writeNormalizedApiModel('tool/api/current.json');
  stdout.writeln('Review tool/api/current.json before committing it.');
}

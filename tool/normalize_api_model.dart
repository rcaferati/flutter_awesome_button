import 'dart:io';

import 'api_model.dart';

void main(List<String> arguments) {
  if (arguments.length != 1) {
    stderr.writeln('usage: dart run tool/normalize_api_model.dart <model>');
    exitCode = 64;
    return;
  }

  writeNormalizedApiModel(arguments.single);
}

import 'dart:convert';
import 'dart:io';

Map<String, Object?> readNormalizedApiModel(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync());
  if (decoded is! Map<String, Object?>) {
    throw FormatException('Expected a JSON object in $path.');
  }
  final packageApi = decoded['packageApi'];
  if (packageApi is! Map<String, Object?>) {
    throw FormatException('Expected packageApi in $path.');
  }
  packageApi['packagePath'] = '<package-root>';
  return decoded;
}

void writeNormalizedApiModel(String path) {
  final normalized = readNormalizedApiModel(path);
  const encoder = JsonEncoder.withIndent('  ');
  File(path).writeAsStringSync('${encoder.convert(normalized)}\n');
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rcaferati_flutter_awesome_button/rcaferati_flutter_awesome_button.dart';

const _warmUpRepetitions = 5;
const _measuredRepetitions = 25;

double _median(List<double> values) {
  final sorted = values.toList()..sort();
  return sorted[sorted.length ~/ 2];
}

Future<double> _runUpdateSequence(WidgetTester tester) async {
  final stopwatch = Stopwatch()..start();
  for (final configuration
      in <({String label, Color color, double height, bool progress})>[
    (label: 'A', color: const Color(0xFF111111), height: 48, progress: false),
    (label: 'B', color: const Color(0xFF222222), height: 52, progress: true),
    (label: 'C', color: const Color(0xFF333333), height: 56, progress: false),
    (label: 'D', color: const Color(0xFF444444), height: 60, progress: false),
  ]) {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: child!,
        ),
        home: Center(
          child: AwesomeButton(
            height: configuration.height,
            progress: configuration.progress,
            style: AwesomeButtonStyle(
              backgroundColor: configuration.color,
            ),
            onPress: ([AwesomeButtonNext? next]) {},
            child: configuration.label,
          ),
        ),
      ),
    );
  }
  stopwatch.stop();

  expect(
    tester.widget<AwesomeButton>(find.byType(AwesomeButton)).child,
    equals('D'),
  );
  await tester.pumpWidget(const SizedBox.shrink());
  return stopwatch.elapsedMicroseconds / 1000;
}

void main() {
  testWidgets('records a rapid package-view update baseline', (tester) async {
    for (var index = 0; index < _warmUpRepetitions; index += 1) {
      await _runUpdateSequence(tester);
    }

    final durations = <double>[];
    for (var index = 0; index < _measuredRepetitions; index += 1) {
      durations.add(await _runUpdateSequence(tester));
    }
    final medianDuration = _median(durations);
    final medianAbsoluteDeviation = _median(
      durations.map((duration) => (duration - medianDuration).abs()).toList(),
    );

    expect(durations.every((duration) => duration.isFinite), isTrue);
    // Informational evidence only: no wall-clock value is a release threshold.
    // ignore: avoid_print
    print(
      jsonEncode(<String, Object>{
        'benchmark': 'rapid-package-view-updates',
        'warmUpRepetitions': _warmUpRepetitions,
        'measuredRepetitions': _measuredRepetitions,
        'updatesPerRepetition': 4,
        'medianDurationMs': double.parse(medianDuration.toStringAsFixed(3)),
        'medianAbsoluteDeviationMs': double.parse(
          medianAbsoluteDeviation.toStringAsFixed(3),
        ),
      }),
    );
  });
}

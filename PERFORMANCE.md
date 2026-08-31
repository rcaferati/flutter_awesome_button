# Performance Evidence

Pass 5 treats performance evidence as informational and establishes no release threshold.

The package-owned benchmark mounts `AwesomeButton`, performs rapid callback, style, content, size, and progress-state replacements, and records the elapsed time for each deterministic update sequence. Run it with:

```sh
flutter test test/performance_baseline_test.dart --reporter expanded
```

Wall-clock values are emitted for declared local comparison only and are never asserted by CI. Future performance changes must retain the observable-behavior checks, rerun the same method on a declared host, and report before/after evidence. This baseline does not authorize a README frame-rate claim.

## Pass 5 local baseline

Recorded on 2026-08-30 using a 14-core Apple M3 Max MacBook Pro with 36 GB memory, macOS 26.6.2 (25G83), arm64, Flutter 3.41.7 (`cc0734ac71`), and Dart 3.11.5 in the Flutter widget-test environment. Reduced Motion was enabled to isolate configuration/update ownership from animation wall time.

After five unrecorded warm-up repetitions, 25 measured repetitions each mounted one package view and applied four callback/style/content/height/progress configurations. The median was 10.043 ms with a median absolute deviation of 0.787 ms. The benchmark also verifies that the final public widget owns the latest configuration before teardown. These values are informational and are not CI assertions.

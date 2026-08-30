# Contributing

## Toolchain

- Flutter 3.41.7 (`cc0734ac71`)
- Dart 3.11.5
- `dart_apitool` 0.23.2 from the package lockfile

Bootstrap the package root with:

```sh
flutter pub get --enforce-lockfile
dart pub get --directory tool/dart_apitool --enforce-lockfile
```

The API tool uses an isolated package-owned manifest because its Analyzer dependency cannot share Flutter 3.41.7's SDK-pinned `meta` version. The isolation changes no library or publication dependency.

Run the complete non-publishing package gate with:

```sh
tool/release-preflight.sh
```

That command checks formatting, fatal analyzer diagnostics, package-owned tests and LCOV generation, the checked-in API model, public documentation with link validation in secure temporary storage, and the pub payload. It does not publish or mutate the reviewed API baseline.

To review an intentional public API change, run `dart run tool/update_api.dart`, inspect `tool/api/current.json`, and update `CHANGELOG.md` plus `tool/api/0.9.1-to-current.md` or later migration evidence. CI runs `tool/check-api-model.sh` and never rewrites the committed model.

Tests belong under `test/`. The source `example/` is part of the pub package and is a manual showcase, not an automated UI-test target. Platform assistive-technology, keyboard, RTL, large-text, and Reduced Motion checks remain manual runtime evidence.

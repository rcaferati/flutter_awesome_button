part of '../awesome_button.dart';

enum _TextMeasurementKind {
  target,
  candidate,
}

@immutable
class _AutoWidthMeasurementRequest {
  const _AutoWidthMeasurementRequest({
    required this.runId,
    required this.requestId,
    required this.kind,
    required this.text,
  });

  final int runId;
  final int requestId;
  final _TextMeasurementKind kind;
  final String text;
}

@immutable
class _AutoWidthMeasurement {
  const _AutoWidthMeasurement({
    required this.runId,
    required this.requestId,
    required this.metricRevision,
    required this.kind,
    required this.text,
    required this.requiredWidth,
    required this.displayedRequiredWidth,
    required this.availableWidth,
    required this.fits,
    required this.externallyConstrained,
  });

  final int runId;
  final int requestId;
  final int metricRevision;
  final _TextMeasurementKind kind;
  final String text;
  final double requiredWidth;
  final double displayedRequiredWidth;
  final double availableWidth;
  final bool fits;
  final bool externallyConstrained;
}

@immutable
class _TargetCommitProof {
  const _TargetCommitProof({
    required this.runId,
    required this.publicationId,
    required this.metricRevision,
    required this.text,
    required this.requiredWidth,
    required this.availableWidth,
    required this.fits,
    required this.externallyConstrained,
  });

  final int runId;
  final int publicationId;
  final int metricRevision;
  final String text;
  final double requiredWidth;
  final double availableWidth;
  final bool fits;
  final bool externallyConstrained;
}

double _roundRequiredWidthToPhysicalPixel(double width, double scale) {
  if (!width.isFinite) {
    return width;
  }
  final safeScale = scale.isFinite && scale > 0 ? scale : 1.0;
  return (width * safeScale).ceilToDouble() / safeScale;
}

double _roundAvailableWidthToPhysicalPixel(double width, double scale) {
  if (!width.isFinite) {
    return width;
  }
  final safeScale = scale.isFinite && scale > 0 ? scale : 1.0;
  return (width * safeScale).floorToDouble() / safeScale;
}

bool _hasPhysicalPixelFit(
  double requiredWidth,
  double availableWidth,
  double scale,
) =>
    _roundAvailableWidthToPhysicalPixel(availableWidth, scale) >=
    _roundRequiredWidthToPhysicalPixel(requiredWidth, scale);

@immutable
class _ButtonAuxiliaryMeasurement {
  const _ButtonAuxiliaryMeasurement({
    required this.revision,
    required this.beforeWidth,
    required this.afterWidth,
  });

  final int revision;
  final double beforeWidth;
  final double afterWidth;

  double get width => beforeWidth + afterWidth;

  @override
  bool operator ==(Object other) =>
      other is _ButtonAuxiliaryMeasurement &&
      revision == other.revision &&
      (beforeWidth - other.beforeWidth).abs() < 0.001 &&
      (afterWidth - other.afterWidth).abs() < 0.001;

  @override
  int get hashCode => Object.hash(
        revision,
        beforeWidth.toStringAsFixed(3),
        afterWidth.toStringAsFixed(3),
      );
}

TextStyle _resolvedButtonLabelTextStyle(
  BuildContext context,
  _ResolvedAwesomeButtonStyle style,
) {
  return DefaultTextStyle.of(context).style.merge(
        TextStyle(
          color: style.foregroundColor,
          fontWeight: FontWeight.w700,
          fontSize: style.textSize,
          height:
              style.textSize > 0 ? style.textLineHeight / style.textSize : null,
          fontFamily: style.textFontFamily,
        ),
      );
}

double _measureButtonLabelOuterWidth({
  required BuildContext context,
  required String text,
  required TextStyle textStyle,
  required EdgeInsets padding,
  required double borderWidth,
  required double contentGap,
  required bool hasBefore,
  required bool hasAfter,
  required _ButtonAuxiliaryMeasurement auxiliary,
}) {
  final defaultTextStyle = DefaultTextStyle.of(context);
  final painter = TextPainter(
    text: TextSpan(text: text, style: textStyle),
    maxLines: 1,
    textAlign: TextAlign.center,
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    locale: Localizations.maybeLocaleOf(context),
    textWidthBasis: defaultTextStyle.textWidthBasis,
    textHeightBehavior: defaultTextStyle.textHeightBehavior,
  )..layout(maxWidth: double.infinity);
  final gapCount = (hasBefore ? 1 : 0) + (hasAfter ? 1 : 0);
  return painter.width +
      auxiliary.width +
      (contentGap * gapCount) +
      padding.horizontal +
      (borderWidth * 2);
}

class _MeasuredButtonRow extends Flex {
  const _MeasuredButtonRow({
    required this.measurementRevision,
    required this.beforeIndex,
    required this.afterIndex,
    required this.onMeasured,
    required super.mainAxisSize,
    required super.mainAxisAlignment,
    required super.children,
  }) : super(direction: Axis.horizontal);

  final int measurementRevision;
  final int? beforeIndex;
  final int? afterIndex;
  final ValueChanged<_ButtonAuxiliaryMeasurement> onMeasured;

  @override
  RenderFlex createRenderObject(BuildContext context) {
    return _RenderMeasuredButtonRow(
      measurementRevision: measurementRevision,
      beforeIndex: beforeIndex,
      afterIndex: afterIndex,
      onMeasured: onMeasured,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: getEffectiveTextDirection(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      clipBehavior: clipBehavior,
      spacing: spacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMeasuredButtonRow renderObject,
  ) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..measurementRevision = measurementRevision
      ..beforeIndex = beforeIndex
      ..afterIndex = afterIndex
      ..onMeasured = onMeasured;
  }
}

class _RenderMeasuredButtonRow extends RenderFlex {
  _RenderMeasuredButtonRow({
    required int measurementRevision,
    required int? beforeIndex,
    required int? afterIndex,
    required ValueChanged<_ButtonAuxiliaryMeasurement> onMeasured,
    required super.mainAxisAlignment,
    required super.mainAxisSize,
    required super.crossAxisAlignment,
    required super.textDirection,
    required super.verticalDirection,
    required super.textBaseline,
    required super.clipBehavior,
    required super.spacing,
  })  : _measurementRevision = measurementRevision,
        _beforeIndex = beforeIndex,
        _afterIndex = afterIndex,
        _onMeasured = onMeasured,
        super(direction: Axis.horizontal);

  int _measurementRevision;
  int? _beforeIndex;
  int? _afterIndex;
  ValueChanged<_ButtonAuxiliaryMeasurement> _onMeasured;
  _ButtonAuxiliaryMeasurement? _lastMeasurement;

  set measurementRevision(int value) {
    if (_measurementRevision == value) {
      return;
    }
    _measurementRevision = value;
    _lastMeasurement = null;
    markNeedsLayout();
  }

  set beforeIndex(int? value) {
    if (_beforeIndex == value) {
      return;
    }
    _beforeIndex = value;
    _lastMeasurement = null;
    markNeedsLayout();
  }

  set afterIndex(int? value) {
    if (_afterIndex == value) {
      return;
    }
    _afterIndex = value;
    _lastMeasurement = null;
    markNeedsLayout();
  }

  set onMeasured(ValueChanged<_ButtonAuxiliaryMeasurement> value) {
    _onMeasured = value;
  }

  RenderBox? _childAt(int? index) {
    if (index == null || index < 0) {
      return null;
    }
    var current = firstChild;
    var currentIndex = 0;
    while (current != null && currentIndex < index) {
      final parentData = current.parentData! as FlexParentData;
      current = parentData.nextSibling;
      currentIndex += 1;
    }
    return currentIndex == index ? current : null;
  }

  @override
  void performLayout() {
    super.performLayout();
    final measurement = _ButtonAuxiliaryMeasurement(
      revision: _measurementRevision,
      beforeWidth: _childAt(_beforeIndex)?.size.width ?? 0,
      afterWidth: _childAt(_afterIndex)?.size.width ?? 0,
    );
    if (_lastMeasurement == measurement) {
      return;
    }
    _lastMeasurement = measurement;
    final callback = _onMeasured;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached && _lastMeasurement == measurement) {
        callback(measurement);
      }
    });
  }
}

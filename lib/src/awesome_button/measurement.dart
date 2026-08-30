part of '../awesome_button.dart';

@immutable
class _AutoWidthMeasurementRequest {
  const _AutoWidthMeasurementRequest({
    required this.requestId,
    required this.text,
  });

  final int requestId;
  final String text;
}

class _AutoWidthMeasurement {
  const _AutoWidthMeasurement({
    required this.requestId,
    required this.width,
  });

  final int requestId;
  final double width;
}

class _AutoWidthMeasurementProbe extends StatelessWidget {
  const _AutoWidthMeasurementProbe({
    required this.requestId,
    required this.text,
    required this.padding,
    required this.borderWidth,
    required this.foregroundColor,
    required this.textSize,
    required this.textLineHeight,
    required this.textFontFamily,
    required this.onMeasured,
  });

  final int requestId;
  final String text;
  final EdgeInsets padding;
  final double borderWidth;
  final Color foregroundColor;
  final double textSize;
  final double textLineHeight;
  final String? textFontFamily;
  final ValueChanged<_AutoWidthMeasurement> onMeasured;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: true,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: TickerMode(
            enabled: false,
            child: OverflowBox(
              alignment: Alignment.topLeft,
              fit: OverflowBoxFit.deferToChild,
              minWidth: 0,
              maxWidth: double.infinity,
              minHeight: 0,
              maxHeight: double.infinity,
              child: _MeasureSize(
                onChange: (size) {
                  onMeasured(
                    _AutoWidthMeasurement(
                      requestId: requestId,
                      width: size.width,
                    ),
                  );
                },
                child: DecoratedBox(
                  key: const ValueKey<String>('aws-btn-auto-width-measure'),
                  decoration: BoxDecoration(
                    border: borderWidth > 0
                        ? Border.all(
                            color: Colors.transparent,
                            width: borderWidth,
                          )
                        : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(borderWidth) + padding,
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        color: foregroundColor,
                        fontWeight: FontWeight.w700,
                        fontSize: textSize,
                        height: textSize > 0 ? textLineHeight / textSize : null,
                        fontFamily: textFontFamily,
                      ),
                      child: Text(
                        text,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({
    required this.onChange,
    required super.child,
  });

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMeasureSize(onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMeasureSize renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _previousSize;

  @override
  void performLayout() {
    super.performLayout();
    final nextSize = child?.size ?? size;

    if (_previousSize == nextSize) {
      return;
    }

    _previousSize = nextSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(nextSize);
    });
  }
}

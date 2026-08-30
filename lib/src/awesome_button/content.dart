part of '../awesome_button.dart';

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.stretch,
    required this.gap,
    required this.before,
    required this.after,
    required this.textStyle,
    required this.alignLogicalLeading,
    required this.auxiliaryMeasurementRevision,
    required this.onAuxiliaryMeasured,
    required this.child,
  });

  final bool stretch;
  final double gap;
  final Widget? before;
  final Widget? after;
  final TextStyle textStyle;
  final bool alignLogicalLeading;
  final int auxiliaryMeasurementRevision;
  final ValueChanged<_ButtonAuxiliaryMeasurement> onAuxiliaryMeasured;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: textStyle,
      child: IconTheme(
        data: IconThemeData(color: textStyle.color),
        child: Builder(
          builder: (context) {
            final entries = <Widget>[
              if (before != null) before!,
              child,
              if (after != null) after!,
            ];

            final rowChildren = <Widget>[];
            int? beforeIndex;
            int? afterIndex;
            for (var index = 0; index < entries.length; index += 1) {
              if (index > 0) {
                rowChildren.add(SizedBox(width: gap));
              }
              final entry = entries[index];
              final isCenterChild = before != null ? index == 1 : index == 0;
              final isBefore = before != null && index == 0;
              final isAfter = after != null && index == entries.length - 1;

              final rowIndex = rowChildren.length;
              if (isBefore) {
                beforeIndex = rowIndex;
              }
              if (isAfter) {
                afterIndex = rowIndex;
              }
              rowChildren.add(
                isCenterChild && stretch ? Flexible(child: entry) : entry,
              );
            }

            return _MeasuredButtonRow(
              measurementRevision: auxiliaryMeasurementRevision,
              beforeIndex: beforeIndex,
              afterIndex: afterIndex,
              onMeasured: onAuxiliaryMeasured,
              mainAxisSize: stretch ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: alignLogicalLeading
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: rowChildren,
            );
          },
        ),
      ),
    );
  }
}

part of '../awesome_button.dart';

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.stretch,
    required this.foregroundColor,
    required this.gap,
    required this.before,
    required this.after,
    required this.textSize,
    required this.textLineHeight,
    required this.textFontFamily,
    required this.child,
  });

  final bool stretch;
  final Color foregroundColor;
  final double gap;
  final Widget? before;
  final Widget? after;
  final double? textSize;
  final double? textLineHeight;
  final String? textFontFamily;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(
        color: foregroundColor,
        fontWeight: FontWeight.w700,
        fontSize: textSize,
        height: textSize != null && textLineHeight != null && textSize! > 0
            ? textLineHeight! / textSize!
            : null,
        fontFamily: textFontFamily,
      ),
      child: IconTheme(
        data: IconThemeData(color: foregroundColor),
        child: Builder(
          builder: (context) {
            final entries = <Widget>[
              if (before != null) before!,
              child,
              if (after != null) after!,
            ];

            final rowChildren = <Widget>[];
            for (var index = 0; index < entries.length; index += 1) {
              if (index > 0) {
                rowChildren.add(SizedBox(width: gap));
              }
              final entry = entries[index];
              final isCenterChild = before != null ? index == 1 : index == 0;

              rowChildren.add(
                isCenterChild && stretch ? Flexible(child: entry) : entry,
              );
            }

            return Row(
              mainAxisSize: stretch ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: rowChildren,
            );
          },
        ),
      ),
    );
  }
}

part of '../awesome_button.dart';

class _ButtonPlaceholder extends StatefulWidget {
  const _ButtonPlaceholder({
    required this.animated,
    required this.backgroundColor,
    required this.height,
  });

  final bool animated;
  final Color backgroundColor;
  final double height;

  @override
  State<_ButtonPlaceholder> createState() => _ButtonPlaceholderState();
}

class _ButtonPlaceholderState extends State<_ButtonPlaceholder>
    with SingleTickerProviderStateMixin {
  static const Duration _loopDuration = Duration(milliseconds: 3223);
  static const Color _barColor = Color.fromRGBO(0, 0, 0, 0.15);

  late final AnimationController _controller;
  double _measuredWidth = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _loopDuration);
    _syncLoop();
  }

  @override
  void didUpdateWidget(covariant _ButtonPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animated != widget.animated) {
      _syncLoop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncLoop() {
    _controller.stop();
    _controller.value = 0;

    if (widget.animated && _measuredWidth > 0) {
      _controller.repeat();
    }
  }

  void _updateMeasuredWidth(double width) {
    if ((_measuredWidth - width).abs() < 0.5) {
      return;
    }

    setState(() {
      _measuredWidth = width;
    });
    _syncLoop();
  }

  double _translateXFor(double width) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(-width), weight: 20),
      TweenSequenceItem(
          tween: Tween<double>(begin: -width, end: width), weight: 30),
      TweenSequenceItem(tween: ConstantTween<double>(width), weight: 20),
      TweenSequenceItem(
          tween: Tween<double>(begin: width, end: -width), weight: 30),
    ]).transform(_controller.value);
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.55,
      child: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            _updateMeasuredWidth(constraints.maxWidth);
          });

          return SizedBox(
            key: const ValueKey<String>('aws-btn-content-placeholder'),
            height: widget.height,
            child: ClipRect(
              child: DecoratedBox(
                decoration: BoxDecoration(color: widget.backgroundColor),
                child: widget.animated
                    ? AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.translate(
                            key: const ValueKey<String>(
                              'aws-btn-content-placeholder-bar',
                            ),
                            offset: Offset(
                              _translateXFor(constraints.maxWidth),
                              0,
                            ),
                            child: child,
                          );
                        },
                        child: SizedBox(
                          width: constraints.maxWidth,
                          height: widget.height,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(color: _barColor),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

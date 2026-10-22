import 'package:flutter/widgets.dart';
import '../atrial_carousel_controller.dart';
import 'indicator_effects.dart';

/// A modern, customizable carousel page indicator widget.
class AtrialCarouselIndicator extends StatelessWidget {
  /// The total number of dots/items.
  final int count;

  /// Optional [AtrialCarouselController] to automatically synchronize indicator position.
  final AtrialCarouselController? controller;

  /// Current active index when manually controlled. Ignored if [controller] is provided.
  final int currentIndex;

  /// The visual effect style for the indicator. Defaults to [ExpandingDotsEffect].
  final AtrialIndicatorEffect effect;

  /// Callback fired when a dot is clicked/tapped with its index.
  final ValueChanged<int>? onDotClicked;

  /// The axis of the indicator dots. Defaults to [Axis.horizontal].
  final Axis axis;

  /// Padding around the indicator.
  final EdgeInsetsGeometry padding;

  const AtrialCarouselIndicator({
    super.key,
    required this.count,
    this.controller,
    this.currentIndex = 0,
    this.effect = const ExpandingDotsEffect(),
    this.onDotClicked,
    this.axis = Axis.horizontal,
    this.padding = const EdgeInsets.all(8.0),
  });

  /// Factory constructor for manual index control without [AtrialCarouselController].
  const AtrialCarouselIndicator.builder({
    super.key,
    required this.count,
    required this.currentIndex,
    this.effect = const ExpandingDotsEffect(),
    this.onDotClicked,
    this.axis = Axis.horizontal,
    this.padding = const EdgeInsets.all(8.0),
  }) : controller = null;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();

    final Size indicatorSize = effect.calculateSize(count);

    Widget buildCustomPaint(double progress) {
      Widget painterWidget = CustomPaint(
        size: indicatorSize,
        painter: _IndicatorPainter(
          effect: effect,
          count: count,
          progress: progress,
        ),
      );

      if (onDotClicked != null) {
        painterWidget = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final double tapPos = axis == Axis.horizontal
                ? details.localPosition.dx
                : details.localPosition.dy;
            final double total = axis == Axis.horizontal
                ? indicatorSize.width
                : indicatorSize.height;
            final double ratio = (tapPos / total).clamp(0.0, 0.999);
            final int targetIndex = (ratio * count).floor();
            onDotClicked?.call(targetIndex);
          },
          child: painterWidget,
        );
      }

      return Padding(
        padding: padding,
        child: painterWidget,
      );
    }

    if (controller != null) {
      return ValueListenableBuilder<double>(
        valueListenable: controller!.scrollNotifier,
        builder: (context, offset, _) {
          // Normalize offset to 0..count
          final double progress = (offset % count + count) % count;
          return buildCustomPaint(progress);
        },
      );
    }

    return buildCustomPaint(currentIndex.toDouble());
  }
}

class _IndicatorPainter extends CustomPainter {
  final AtrialIndicatorEffect effect;
  final int count;
  final double progress;

  _IndicatorPainter({
    required this.effect,
    required this.count,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    effect.paint(canvas, size, count, progress);
  }

  @override
  bool shouldRepaint(covariant _IndicatorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.count != count ||
        oldDelegate.effect != effect;
  }
}

import 'package:flutter/widgets.dart';

/// Base class for indicator visual effects.
abstract class AtrialIndicatorEffect {
  /// The width of inactive dots.
  final double dotWidth;

  /// The height of inactive dots.
  final double dotHeight;

  /// The horizontal or vertical spacing between dots.
  final double spacing;

  /// The corner radius of the dots.
  final Radius radius;

  /// The color of inactive dots.
  final Color dotColor;

  /// The color of the active dot.
  final Color activeDotColor;

  /// Border stroke width if stroked dots are used.
  final double strokeWidth;

  /// Painting style (fill or stroke).
  final PaintingStyle paintStyle;

  const AtrialIndicatorEffect({
    this.dotWidth = 8.0,
    this.dotHeight = 8.0,
    this.spacing = 8.0,
    this.radius = const Radius.circular(4.0),
    this.dotColor = const Color(0xFFBDBDBD),
    this.activeDotColor = const Color(0xFF2196F3),
    this.strokeWidth = 1.0,
    this.paintStyle = PaintingStyle.fill,
  });

  /// Calculates total size of the indicator given [count].
  Size calculateSize(int count) {
    if (count <= 0) return Size.zero;
    final double totalWidth = (dotWidth * count) + (spacing * (count - 1));
    return Size(totalWidth, dotHeight);
  }

  /// Paints the dots onto the canvas.
  void paint(Canvas canvas, Size size, int count, double progress);
}

/// Slide effect where active dot slides over inactive dots.
class SlideIndicatorEffect extends AtrialIndicatorEffect {
  const SlideIndicatorEffect({
    super.dotWidth = 8.0,
    super.dotHeight = 8.0,
    super.spacing = 8.0,
    super.radius = const Radius.circular(4.0),
    super.dotColor = const Color(0xFFE0E0E0),
    super.activeDotColor = const Color(0xFF1E88E5),
  });

  @override
  void paint(Canvas canvas, Size size, int count, double progress) {
    final Paint inactivePaint = Paint()
      ..color = dotColor
      ..style = paintStyle
      ..strokeWidth = strokeWidth;

    final Paint activePaint = Paint()
      ..color = activeDotColor
      ..style = paintStyle;

    // Draw inactive dots
    for (int i = 0; i < count; i++) {
      final double x = i * (dotWidth + spacing);
      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, dotWidth, dotHeight),
        radius,
      );
      canvas.drawRRect(rrect, inactivePaint);
    }

    // Draw sliding active dot
    final double clampedProgress = progress.clamp(0.0, (count - 1).toDouble());
    final double activeX = clampedProgress * (dotWidth + spacing);
    final RRect activeRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(activeX, 0, dotWidth, dotHeight),
      radius,
    );
    canvas.drawRRect(activeRRect, activePaint);
  }
}

/// Expanding effect where active dot smoothly expands into a wider pill.
class ExpandingDotsEffect extends AtrialIndicatorEffect {
  /// The factor by which the active dot expands (e.g. 3.0 means 3x width).
  final double expansionFactor;

  const ExpandingDotsEffect({
    super.dotWidth = 8.0,
    super.dotHeight = 8.0,
    super.spacing = 8.0,
    super.radius = const Radius.circular(4.0),
    super.dotColor = const Color(0xFFE0E0E0),
    super.activeDotColor = const Color(0xFF1E88E5),
    this.expansionFactor = 2.8,
  });

  @override
  Size calculateSize(int count) {
    if (count <= 0) return Size.zero;
    final double activeWidth = dotWidth * expansionFactor;
    final double totalWidth =
        activeWidth + (dotWidth * (count - 1)) + (spacing * (count - 1));
    return Size(totalWidth, dotHeight);
  }

  @override
  void paint(Canvas canvas, Size size, int count, double progress) {
    final Paint inactivePaint = Paint()..color = dotColor;

    final int activeIndex = progress.floor().clamp(0, count - 1);
    final double transition = (progress - activeIndex).clamp(0.0, 1.0);
    final double activeWidth = dotWidth * expansionFactor;
    final double deltaWidth = activeWidth - dotWidth;

    double currentX = 0.0;
    for (int i = 0; i < count; i++) {
      double width = dotWidth;
      Color color = dotColor;

      if (i == activeIndex) {
        width = dotWidth + deltaWidth * (1.0 - transition);
        color =
            Color.lerp(activeDotColor, dotColor, transition) ?? activeDotColor;
      } else if (i == activeIndex + 1) {
        width = dotWidth + deltaWidth * transition;
        color = Color.lerp(dotColor, activeDotColor, transition) ?? dotColor;
      }

      final Paint paint = (i == activeIndex || i == activeIndex + 1)
          ? (Paint()..color = color)
          : inactivePaint;

      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(currentX, 0, width, dotHeight),
        radius,
      );
      canvas.drawRRect(rrect, paint);
      currentX += width + spacing;
    }
  }
}

/// Worm effect where active dot stretches and pulls like a worm.
class WormIndicatorEffect extends AtrialIndicatorEffect {
  const WormIndicatorEffect({
    super.dotWidth = 10.0,
    super.dotHeight = 10.0,
    super.spacing = 8.0,
    super.radius = const Radius.circular(5.0),
    super.dotColor = const Color(0xFFE0E0E0),
    super.activeDotColor = const Color(0xFF1E88E5),
  });

  @override
  void paint(Canvas canvas, Size size, int count, double progress) {
    final Paint inactivePaint = Paint()..color = dotColor;
    final Paint activePaint = Paint()..color = activeDotColor;

    // Draw background dots
    for (int i = 0; i < count; i++) {
      final double x = i * (dotWidth + spacing);
      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, dotWidth, dotHeight),
        radius,
      );
      canvas.drawRRect(rrect, inactivePaint);
    }

    final double clampedProgress = progress.clamp(0.0, (count - 1).toDouble());
    final int current = clampedProgress.floor();
    final double t = clampedProgress - current;

    final double dotDelta = dotWidth + spacing;
    double left;
    double right;

    if (t <= 0.5) {
      final double headT = t * 2.0;
      left = current * dotDelta;
      right = (current * dotDelta) + dotWidth + (headT * dotDelta);
    } else {
      final double tailT = (t - 0.5) * 2.0;
      left = (current * dotDelta) + (tailT * dotDelta);
      right = ((current + 1) * dotDelta) + dotWidth;
    }

    final RRect wormRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(left, 0, right, dotHeight),
      radius,
    );
    canvas.drawRRect(wormRRect, activePaint);
  }
}

/// Scale effect where active dot smoothly enlarges.
class ScaleIndicatorEffect extends AtrialIndicatorEffect {
  /// The scale multiplier for the active dot (e.g. 1.5).
  final double scale;

  const ScaleIndicatorEffect({
    super.dotWidth = 8.0,
    super.dotHeight = 8.0,
    super.spacing = 10.0,
    super.radius = const Radius.circular(4.0),
    super.dotColor = const Color(0xFFE0E0E0),
    super.activeDotColor = const Color(0xFF1E88E5),
    this.scale = 1.5,
  });

  @override
  Size calculateSize(int count) {
    if (count <= 0) return Size.zero;
    final double maxW = dotWidth * scale;
    final double maxH = dotHeight * scale;
    final double totalWidth = (maxW * count) + (spacing * (count - 1));
    return Size(totalWidth, maxH);
  }

  @override
  void paint(Canvas canvas, Size size, int count, double progress) {
    final double maxH = dotHeight * scale;
    final int activeIndex = progress.floor().clamp(0, count - 1);
    final double transition = (progress - activeIndex).clamp(0.0, 1.0);

    for (int i = 0; i < count; i++) {
      double currentScale = 1.0;
      Color color = dotColor;

      if (i == activeIndex) {
        currentScale = scale - ((scale - 1.0) * transition);
        color =
            Color.lerp(activeDotColor, dotColor, transition) ?? activeDotColor;
      } else if (i == activeIndex + 1) {
        currentScale = 1.0 + ((scale - 1.0) * transition);
        color = Color.lerp(dotColor, activeDotColor, transition) ?? dotColor;
      }

      final double w = dotWidth * currentScale;
      final double h = dotHeight * currentScale;
      final double cx =
          (i * (dotWidth * scale + spacing)) + (dotWidth * scale / 2);
      final double cy = maxH / 2;

      final Rect rect =
          Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
      final RRect rrect = RRect.fromRectAndRadius(rect, radius);
      canvas.drawRRect(rrect, Paint()..color = color);
    }
  }
}

/// Color transition effect where dots smoothly interpolate color.
class ColorTransitionEffect extends AtrialIndicatorEffect {
  const ColorTransitionEffect({
    super.dotWidth = 8.0,
    super.dotHeight = 8.0,
    super.spacing = 8.0,
    super.radius = const Radius.circular(4.0),
    super.dotColor = const Color(0xFFE0E0E0),
    super.activeDotColor = const Color(0xFF1E88E5),
  });

  @override
  void paint(Canvas canvas, Size size, int count, double progress) {
    final int activeIndex = progress.floor().clamp(0, count - 1);
    final double transition = (progress - activeIndex).clamp(0.0, 1.0);

    for (int i = 0; i < count; i++) {
      Color color = dotColor;
      if (i == activeIndex) {
        color =
            Color.lerp(activeDotColor, dotColor, transition) ?? activeDotColor;
      } else if (i == activeIndex + 1) {
        color = Color.lerp(dotColor, activeDotColor, transition) ?? dotColor;
      }

      final double x = i * (dotWidth + spacing);
      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, dotWidth, dotHeight),
        radius,
      );
      canvas.drawRRect(rrect, Paint()..color = color);
    }
  }
}

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

  /// Creates an indicator effect configuration.
  const AtrialIndicatorEffect({
    this.dotWidth = 8.0,
    this.dotHeight = 8.0,
    this.spacing = 8.0,
    this.radius = const Radius.circular(4.0),
    this.dotColor = const Color(0xFFBDBDBD),
    this.activeDotColor = const Color(0xFF2196F3),
    this.strokeWidth = 1.0,
    this.paintStyle = PaintingStyle.fill,
  })  : assert(dotWidth > 0.0, 'dotWidth must be > 0.0'),
        assert(dotHeight > 0.0, 'dotHeight must be > 0.0'),
        assert(spacing >= 0.0, 'spacing must be >= 0.0'),
        assert(strokeWidth >= 0.0, 'strokeWidth must be >= 0.0');

  /// Helper to build a configured [Paint] with [color].
  @protected
  Paint buildPaint(Color color) {
    return Paint()
      ..color = color
      ..style = paintStyle
      ..strokeWidth = strokeWidth;
  }

  /// Calculates total unrotated size of the indicator given [count].
  Size calculateSize(int count) {
    if (count <= 0) return Size.zero;
    final double totalWidth = (dotWidth * count) + (spacing * (count - 1));
    return Size(totalWidth, dotHeight);
  }

  /// Resolves the dot index (`0 <= index < count`) for a local [dx] tap coordinate.
  int hitTestDots(double dx, int count, double progress) {
    if (count <= 0) return -1;
    final Size size = calculateSize(count);
    if (size.width <= 0) return 0;
    final double clamped = dx.clamp(0.0, size.width);
    final double stride = dotWidth + spacing;
    if (stride <= 0) return 0;
    return ((clamped + spacing / 2) / stride).floor().clamp(0, count - 1);
  }

  /// Paints the dots onto the canvas.
  void paint(Canvas canvas, Size size, int count, double progress);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other.runtimeType == runtimeType &&
        other is AtrialIndicatorEffect &&
        other.dotWidth == dotWidth &&
        other.dotHeight == dotHeight &&
        other.spacing == spacing &&
        other.radius == radius &&
        other.dotColor == dotColor &&
        other.activeDotColor == activeDotColor &&
        other.strokeWidth == strokeWidth &&
        other.paintStyle == paintStyle;
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        dotWidth,
        dotHeight,
        spacing,
        radius,
        dotColor,
        activeDotColor,
        strokeWidth,
        paintStyle,
      );
}

/// Slide effect where active dot slides over inactive dots.
class SlideIndicatorEffect extends AtrialIndicatorEffect {
  /// Creates a [SlideIndicatorEffect].
  const SlideIndicatorEffect({
    super.dotWidth = 8.0,
    super.dotHeight = 8.0,
    super.spacing = 8.0,
    super.radius = const Radius.circular(4.0),
    super.dotColor = const Color(0xFFE0E0E0),
    super.activeDotColor = const Color(0xFF1E88E5),
    super.strokeWidth = 1.0,
    super.paintStyle = PaintingStyle.fill,
  });

  @override
  void paint(Canvas canvas, Size size, int count, double progress) {
    if (count <= 0) return;

    final Paint inactivePaint = buildPaint(dotColor);
    final Paint activePaint = Paint()
      ..color = activeDotColor
      ..style = PaintingStyle.fill;

    final double stride = dotWidth + spacing;

    for (int i = 0; i < count; i++) {
      final double x = i * stride;
      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, dotWidth, dotHeight),
        radius,
      );
      canvas.drawRRect(rrect, inactivePaint);
    }

    final double normalized = ((progress % count) + count) % count;
    final double activeX;
    if (normalized <= count - 1) {
      activeX = normalized * stride;
    } else {
      final double wrapT = normalized - (count - 1);
      activeX = (count - 1) * (1.0 - wrapT) * stride;
    }

    final RRect activeRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(activeX, 0, dotWidth, dotHeight),
      radius,
    );
    canvas.drawRRect(activeRRect, activePaint);
  }
}

/// Expanding effect where active dot smoothly expands into a wider pill.
class ExpandingDotsEffect extends AtrialIndicatorEffect {
  /// The factor by which the active dot expands (e.g. `3.0` means 3x width).
  final double expansionFactor;

  /// Creates an [ExpandingDotsEffect].
  const ExpandingDotsEffect({
    super.dotWidth = 8.0,
    super.dotHeight = 8.0,
    super.spacing = 8.0,
    super.radius = const Radius.circular(4.0),
    super.dotColor = const Color(0xFFE0E0E0),
    super.activeDotColor = const Color(0xFF1E88E5),
    super.strokeWidth = 1.0,
    super.paintStyle = PaintingStyle.fill,
    this.expansionFactor = 2.8,
  }) : assert(expansionFactor > 1.0, 'expansionFactor must be > 1.0');

  @override
  Size calculateSize(int count) {
    if (count <= 0) return Size.zero;
    final double activeWidth = dotWidth * expansionFactor;
    final double totalWidth =
        activeWidth + (dotWidth * (count - 1)) + (spacing * (count - 1));
    return Size(totalWidth, dotHeight);
  }

  @override
  int hitTestDots(double dx, int count, double progress) {
    if (count <= 0) return -1;
    final double normalized = ((progress % count) + count) % count;
    final int activeIndex = normalized.floor().clamp(0, count - 1);
    final int nextIndex = (activeIndex + 1) % count;
    final double transition = (normalized - activeIndex).clamp(0.0, 1.0);
    final double deltaWidth = (dotWidth * expansionFactor) - dotWidth;

    double currentX = 0.0;
    for (int i = 0; i < count; i++) {
      double width = dotWidth;
      if (i == activeIndex) {
        width = dotWidth + deltaWidth * (1.0 - transition);
      } else if (i == nextIndex && transition > 0.0) {
        width = dotWidth + deltaWidth * transition;
      }

      final double hitEnd = currentX + width + (spacing / 2);
      if (dx <= hitEnd || i == count - 1) {
        return i;
      }
      currentX += width + spacing;
    }
    return count - 1;
  }

  @override
  void paint(Canvas canvas, Size size, int count, double progress) {
    if (count <= 0) return;

    final Paint inactivePaint = buildPaint(dotColor);
    final double normalized = ((progress % count) + count) % count;
    final int activeIndex = normalized.floor().clamp(0, count - 1);
    final int nextIndex = (activeIndex + 1) % count;
    final double transition = (normalized - activeIndex).clamp(0.0, 1.0);
    final double activeWidth = dotWidth * expansionFactor;
    final double deltaWidth = activeWidth - dotWidth;

    double currentX = 0.0;
    for (int i = 0; i < count; i++) {
      double width = dotWidth;
      Color color = dotColor;
      bool isTransitioning = false;

      if (i == activeIndex) {
        width = dotWidth + deltaWidth * (1.0 - transition);
        color =
            Color.lerp(activeDotColor, dotColor, transition) ?? activeDotColor;
        isTransitioning = true;
      } else if (i == nextIndex && transition > 0.0) {
        width = dotWidth + deltaWidth * transition;
        color = Color.lerp(dotColor, activeDotColor, transition) ?? dotColor;
        isTransitioning = true;
      }

      final Paint paint = isTransitioning ? buildPaint(color) : inactivePaint;

      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(currentX, 0, width, dotHeight),
        radius,
      );
      canvas.drawRRect(rrect, paint);
      currentX += width + spacing;
    }
  }

  @override
  bool operator ==(Object other) =>
      super == other &&
      other is ExpandingDotsEffect &&
      other.expansionFactor == expansionFactor;

  @override
  int get hashCode => Object.hash(super.hashCode, expansionFactor);
}

/// Worm effect where active dot stretches and pulls like a worm.
class WormIndicatorEffect extends AtrialIndicatorEffect {
  /// Creates a [WormIndicatorEffect].
  const WormIndicatorEffect({
    super.dotWidth = 10.0,
    super.dotHeight = 10.0,
    super.spacing = 8.0,
    super.radius = const Radius.circular(5.0),
    super.dotColor = const Color(0xFFE0E0E0),
    super.activeDotColor = const Color(0xFF1E88E5),
    super.strokeWidth = 1.0,
    super.paintStyle = PaintingStyle.fill,
  });

  @override
  void paint(Canvas canvas, Size size, int count, double progress) {
    if (count <= 0) return;

    final Paint inactivePaint = buildPaint(dotColor);
    final Paint activePaint = Paint()
      ..color = activeDotColor
      ..style = PaintingStyle.fill;

    final double dotDelta = dotWidth + spacing;

    for (int i = 0; i < count; i++) {
      final double x = i * dotDelta;
      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, dotWidth, dotHeight),
        radius,
      );
      canvas.drawRRect(rrect, inactivePaint);
    }

    final double normalized = ((progress % count) + count) % count;
    double left;
    double right;

    if (normalized <= count - 1) {
      final int current = normalized.floor();
      final double t = normalized - current;

      if (t <= 0.5) {
        final double headT = t * 2.0;
        left = current * dotDelta;
        right = (current * dotDelta) + dotWidth + (headT * dotDelta);
      } else {
        final double tailT = (t - 0.5) * 2.0;
        left = (current * dotDelta) + (tailT * dotDelta);
        right = ((current + 1) * dotDelta) + dotWidth;
      }
    } else {
      final double wrapT = normalized - (count - 1);
      final double maxSpan = (count - 1) * dotDelta;
      if (wrapT <= 0.5) {
        left = maxSpan * (1.0 - wrapT * 2.0);
        right = maxSpan + dotWidth;
      } else {
        left = 0.0;
        right = dotWidth + maxSpan * (1.0 - (wrapT - 0.5) * 2.0);
      }
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
  /// The scale multiplier for the active dot (e.g. `1.5`).
  final double scale;

  /// Creates a [ScaleIndicatorEffect].
  const ScaleIndicatorEffect({
    super.dotWidth = 8.0,
    super.dotHeight = 8.0,
    super.spacing = 10.0,
    super.radius = const Radius.circular(4.0),
    super.dotColor = const Color(0xFFE0E0E0),
    super.activeDotColor = const Color(0xFF1E88E5),
    super.strokeWidth = 1.0,
    super.paintStyle = PaintingStyle.fill,
    this.scale = 1.5,
  }) : assert(scale > 0.0, 'scale must be > 0.0');

  @override
  Size calculateSize(int count) {
    if (count <= 0) return Size.zero;
    final double maxW = dotWidth * scale;
    final double maxH = dotHeight * scale;
    final double totalWidth = (maxW * count) + (spacing * (count - 1));
    return Size(totalWidth, maxH);
  }

  @override
  int hitTestDots(double dx, int count, double progress) {
    if (count <= 0) return -1;
    final Size size = calculateSize(count);
    if (size.width <= 0) return 0;
    final double clamped = dx.clamp(0.0, size.width);
    final double stride = (dotWidth * scale) + spacing;
    return ((clamped + spacing / 2) / stride).floor().clamp(0, count - 1);
  }

  @override
  void paint(Canvas canvas, Size size, int count, double progress) {
    if (count <= 0) return;

    final double maxH = dotHeight * scale;
    final double normalized = ((progress % count) + count) % count;
    final int activeIndex = normalized.floor().clamp(0, count - 1);
    final int nextIndex = (activeIndex + 1) % count;
    final double transition = (normalized - activeIndex).clamp(0.0, 1.0);

    for (int i = 0; i < count; i++) {
      double currentScale = 1.0;
      Color color = dotColor;

      if (i == activeIndex) {
        currentScale = scale - ((scale - 1.0) * transition);
        color =
            Color.lerp(activeDotColor, dotColor, transition) ?? activeDotColor;
      } else if (i == nextIndex && transition > 0.0) {
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
      canvas.drawRRect(rrect, buildPaint(color));
    }
  }

  @override
  bool operator ==(Object other) =>
      super == other && other is ScaleIndicatorEffect && other.scale == scale;

  @override
  int get hashCode => Object.hash(super.hashCode, scale);
}

/// Color transition effect where dots smoothly interpolate color.
class ColorTransitionEffect extends AtrialIndicatorEffect {
  /// Creates a [ColorTransitionEffect].
  const ColorTransitionEffect({
    super.dotWidth = 8.0,
    super.dotHeight = 8.0,
    super.spacing = 8.0,
    super.radius = const Radius.circular(4.0),
    super.dotColor = const Color(0xFFE0E0E0),
    super.activeDotColor = const Color(0xFF1E88E5),
    super.strokeWidth = 1.0,
    super.paintStyle = PaintingStyle.fill,
  });

  @override
  void paint(Canvas canvas, Size size, int count, double progress) {
    if (count <= 0) return;

    final double normalized = ((progress % count) + count) % count;
    final int activeIndex = normalized.floor().clamp(0, count - 1);
    final int nextIndex = (activeIndex + 1) % count;
    final double transition = (normalized - activeIndex).clamp(0.0, 1.0);

    for (int i = 0; i < count; i++) {
      Color color = dotColor;
      if (i == activeIndex) {
        color =
            Color.lerp(activeDotColor, dotColor, transition) ?? activeDotColor;
      } else if (i == nextIndex && transition > 0.0) {
        color = Color.lerp(dotColor, activeDotColor, transition) ?? dotColor;
      }

      final double x = i * (dotWidth + spacing);
      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, dotWidth, dotHeight),
        radius,
      );
      canvas.drawRRect(rrect, buildPaint(color));
    }
  }
}

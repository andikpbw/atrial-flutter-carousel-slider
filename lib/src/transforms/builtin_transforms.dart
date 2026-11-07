import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'slide_transform.dart';

/// Standard slide transition with customizable minimum scale and opacity.
class DefaultSlideTransform extends AtrialSlideTransform {
  /// Minimum scale applied to non-centered slides. Default is `0.85`.
  final double minScale;

  /// Minimum opacity applied to non-centered slides. Default is `0.6`.
  final double minOpacity;

  /// Creates a [DefaultSlideTransform].
  const DefaultSlideTransform({
    this.minScale = 0.85,
    this.minOpacity = 0.6,
  })  : assert(minScale >= 0.0 && minScale <= 1.0),
        assert(minOpacity >= 0.0 && minOpacity <= 1.0);

  @override
  Widget transform(
    BuildContext context,
    Widget child,
    AtrialTransformDetails details,
  ) {
    final double dist = details.position.abs().clamp(0.0, 1.0);
    final double scale = (1.0 - (1.0 - minScale) * dist).clamp(0.0, 1.0);
    final double opacity = (1.0 - (1.0 - minOpacity) * dist).clamp(0.0, 1.0);

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: child,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DefaultSlideTransform &&
          other.minScale == minScale &&
          other.minOpacity == minOpacity;

  @override
  int get hashCode => Object.hash(minScale, minOpacity);
}

/// 3D Cube rotation transition effect.
class CubeSlideTransform extends AtrialSlideTransform {
  /// Matrix perspective factor. Defaults to `0.0015`.
  final double perspective;

  /// Whether to fade out slides as they rotate away. Defaults to `true`.
  final bool fade;

  /// Creates a [CubeSlideTransform].
  const CubeSlideTransform({
    this.perspective = 0.0015,
    this.fade = true,
  });

  @override
  Widget transform(
    BuildContext context,
    Widget child,
    AtrialTransformDetails details,
  ) {
    final double pos = details.position;
    if (pos < -1.0 || pos > 1.0) {
      return const SizedBox.shrink();
    }

    final bool isHorizontal = details.scrollDirection == Axis.horizontal;
    final double angle = pos * (math.pi / 2);
    final Alignment origin = isHorizontal
        ? (pos > 0 ? Alignment.centerLeft : Alignment.centerRight)
        : (pos > 0 ? Alignment.topCenter : Alignment.bottomCenter);

    final Matrix4 matrix = Matrix4.identity()..setEntry(3, 2, perspective);
    if (isHorizontal) {
      matrix.rotateY(angle);
    } else {
      matrix.rotateX(-angle);
    }

    Widget transformed = Transform(
      transform: matrix,
      alignment: origin,
      child: child,
    );

    if (fade) {
      final double opacity = (1.0 - pos.abs() * 0.4).clamp(0.0, 1.0);
      transformed = Opacity(opacity: opacity, child: transformed);
    }

    return transformed;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CubeSlideTransform &&
          other.perspective == perspective &&
          other.fade == fade;

  @override
  int get hashCode => Object.hash(perspective, fade);
}

/// Accordion fold transition effect.
class AccordionSlideTransform extends AtrialSlideTransform {
  /// Creates an [AccordionSlideTransform].
  const AccordionSlideTransform();

  @override
  Widget transform(
    BuildContext context,
    Widget child,
    AtrialTransformDetails details,
  ) {
    final double pos = details.position;
    if (pos < -1.0 || pos > 1.0) {
      return const SizedBox.shrink();
    }

    final double scale = (1.0 - pos.abs()).clamp(0.0, 1.0);
    final Alignment alignment = details.scrollDirection == Axis.horizontal
        ? (pos > 0 ? Alignment.centerLeft : Alignment.centerRight)
        : (pos > 0 ? Alignment.topCenter : Alignment.bottomCenter);

    return Transform.scale(
      scaleX: details.scrollDirection == Axis.horizontal ? scale : 1.0,
      scaleY: details.scrollDirection == Axis.vertical ? scale : 1.0,
      alignment: alignment,
      child: child,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AccordionSlideTransform;

  @override
  int get hashCode => (AccordionSlideTransform).hashCode;
}

/// Classic Zoom-Out page transition effect.
class ZoomOutSlideTransform extends AtrialSlideTransform {
  /// Minimum scale factor applied during transition. Defaults to `0.85`.
  final double minScale;

  /// Minimum opacity applied during transition. Defaults to `0.5`.
  final double minAlpha;

  /// Creates a [ZoomOutSlideTransform].
  const ZoomOutSlideTransform({
    this.minScale = 0.85,
    this.minAlpha = 0.5,
  })  : assert(minScale >= 0.0 && minScale <= 1.0),
        assert(minAlpha >= 0.0 && minAlpha <= 1.0);

  @override
  Widget transform(
    BuildContext context,
    Widget child,
    AtrialTransformDetails details,
  ) {
    final double pos = details.position;
    if (pos < -1.0 || pos > 1.0) {
      return const SizedBox.shrink();
    }

    final double scaleFactor = math.max(minScale, 1.0 - pos.abs());
    final double alphaFactor = minScale >= 1.0
        ? (1.0 - pos.abs() * (1.0 - minAlpha))
        : minAlpha +
            (scaleFactor - minScale) / (1.0 - minScale) * (1.0 - minAlpha);

    return Transform.scale(
      scale: scaleFactor.clamp(0.0, 1.0),
      child: Opacity(
        opacity: alphaFactor.clamp(0.0, 1.0),
        child: child,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoomOutSlideTransform &&
          other.minScale == minScale &&
          other.minAlpha == minAlpha;

  @override
  int get hashCode => Object.hash(minScale, minAlpha);
}

/// Depth transition where incoming slides scale up and fade in smoothly.
class DepthSlideTransform extends AtrialSlideTransform {
  /// Minimum scale factor for incoming slides. Defaults to `0.75`.
  final double minScale;

  /// Creates a [DepthSlideTransform].
  const DepthSlideTransform({
    this.minScale = 0.75,
  }) : assert(minScale >= 0.0 && minScale <= 1.0);

  @override
  Widget transform(
    BuildContext context,
    Widget child,
    AtrialTransformDetails details,
  ) {
    final double pos = details.position;
    if (pos < -1.0 || pos > 1.0) {
      return const SizedBox.shrink();
    }

    if (pos <= 0) {
      return child;
    } else {
      final double scaleFactor =
          (minScale + (1.0 - minScale) * (1.0 - pos)).clamp(0.0, 1.0);
      final double opacityFactor = (1.0 - pos).clamp(0.0, 1.0);

      return Transform.scale(
        scale: scaleFactor,
        child: Opacity(
          opacity: opacityFactor,
          child: child,
        ),
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepthSlideTransform && other.minScale == minScale;

  @override
  int get hashCode => minScale.hashCode;
}

/// Parallax transition effect that shifts content slightly opposite to the scroll direction.
class ParallaxSlideTransform extends AtrialSlideTransform {
  /// The factor determining the parallax speed (typically `0.2` to `0.5`).
  final double parallaxFactor;

  /// Creates a [ParallaxSlideTransform].
  const ParallaxSlideTransform({
    this.parallaxFactor = 0.35,
  });

  @override
  Widget transform(
    BuildContext context,
    Widget child,
    AtrialTransformDetails details,
  ) {
    final double pos = details.position;
    if (pos < -1.0 || pos > 1.0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double dimension = details.scrollDirection == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        final double offset =
            dimension.isFinite ? (-pos * dimension * parallaxFactor) : 0.0;

        final Offset translation = details.scrollDirection == Axis.horizontal
            ? Offset(offset, 0)
            : Offset(0, offset);

        return ClipRect(
          child: Transform.translate(
            offset: translation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParallaxSlideTransform && other.parallaxFactor == parallaxFactor;

  @override
  int get hashCode => parallaxFactor.hashCode;
}

/// 3D Flip transition effect around the center axis.
class FlipSlideTransform extends AtrialSlideTransform {
  /// Matrix perspective factor. Defaults to `0.002`.
  final double perspective;

  /// Creates a [FlipSlideTransform].
  const FlipSlideTransform({
    this.perspective = 0.002,
  });

  @override
  Widget transform(
    BuildContext context,
    Widget child,
    AtrialTransformDetails details,
  ) {
    final double pos = details.position;
    if (pos < -0.5 || pos > 0.5) {
      return const SizedBox.shrink();
    }

    final double rotation = -pos * math.pi;
    final Matrix4 matrix = Matrix4.identity()..setEntry(3, 2, perspective);

    if (details.scrollDirection == Axis.horizontal) {
      matrix.rotateY(rotation);
    } else {
      matrix.rotateX(rotation);
    }

    return Transform(
      transform: matrix,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlipSlideTransform && other.perspective == perspective;

  @override
  int get hashCode => perspective.hashCode;
}

/// Modern Card Stack transition where adjacent cards tuck neatly behind.
class CardStackSlideTransform extends AtrialSlideTransform {
  /// Scale reduction step applied to stacked cards. Defaults to `0.08`.
  final double scaleStep;

  /// Pixel translation step applied to stacked cards. Defaults to `18.0`.
  final double offsetStep;

  /// Creates a [CardStackSlideTransform].
  const CardStackSlideTransform({
    this.scaleStep = 0.08,
    this.offsetStep = 18.0,
  });

  @override
  Widget transform(
    BuildContext context,
    Widget child,
    AtrialTransformDetails details,
  ) {
    final double pos = details.position;
    if (pos < -1.0 || pos > 1.0) {
      return const SizedBox.shrink();
    }

    if (pos <= 0) {
      return Transform.scale(
        scale: (1.0 + (pos * 0.1)).clamp(0.0, 1.0),
        child: Opacity(
          opacity: (1.0 + pos).clamp(0.0, 1.0),
          child: child,
        ),
      );
    } else {
      final double scale = (1.0 - (pos * scaleStep)).clamp(0.5, 1.0);
      final double translate = pos * offsetStep;

      final Offset offset = details.scrollDirection == Axis.horizontal
          ? Offset(-translate, 0)
          : Offset(0, -translate);

      return Transform.translate(
        offset: offset,
        child: Transform.scale(
          scale: scale,
          child: child,
        ),
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardStackSlideTransform &&
          other.scaleStep == scaleStep &&
          other.offsetStep == offsetStep;

  @override
  int get hashCode => Object.hash(scaleStep, offsetStep);
}

/// 3D CoverFlow transition effect that tilts and scales side slides inward.
class CoverFlowSlideTransform extends AtrialSlideTransform {
  /// Maximum tilt angle in radians for side slides. Defaults to `math.pi / 5` (~36°).
  final double maxAngle;

  /// Minimum scale factor for side slides. Defaults to `0.82`.
  final double minScale;

  /// Minimum opacity for side slides. Defaults to `0.75`.
  final double minOpacity;

  /// Matrix perspective factor. Defaults to `0.002`.
  final double perspective;

  /// Creates a [CoverFlowSlideTransform].
  const CoverFlowSlideTransform({
    this.maxAngle = math.pi / 5,
    this.minScale = 0.82,
    this.minOpacity = 0.75,
    this.perspective = 0.002,
  })  : assert(minScale >= 0.0 && minScale <= 1.0),
        assert(minOpacity >= 0.0 && minOpacity <= 1.0);

  @override
  Widget transform(
    BuildContext context,
    Widget child,
    AtrialTransformDetails details,
  ) {
    final double pos = details.position;
    if (pos < -2.0 || pos > 2.0) {
      return const SizedBox.shrink();
    }

    final double clampedPos = pos.clamp(-1.0, 1.0);
    final double dist = clampedPos.abs();
    final double scale = (1.0 - (1.0 - minScale) * dist).clamp(0.0, 1.0);
    final double opacity = (1.0 - (1.0 - minOpacity) * dist).clamp(0.0, 1.0);
    final double angle = -clampedPos * maxAngle;

    final Matrix4 matrix = Matrix4.identity()..setEntry(3, 2, perspective);
    if (details.scrollDirection == Axis.horizontal) {
      matrix.rotateY(angle);
    } else {
      matrix.rotateX(-angle);
    }
    matrix.multiply(Matrix4.diagonal3Values(scale, scale, 1.0));

    return Opacity(
      opacity: opacity,
      child: Transform(
        transform: matrix,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoverFlowSlideTransform &&
          other.maxAngle == maxAngle &&
          other.minScale == minScale &&
          other.minOpacity == minOpacity &&
          other.perspective == perspective;

  @override
  int get hashCode => Object.hash(maxAngle, minScale, minOpacity, perspective);
}

import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'slide_transform.dart';

/// Standard slide transition with customizable minimum scale and opacity.
class DefaultSlideTransform extends AtrialSlideTransform {
  /// Minimum scale applied to non-centered slides. Default is 0.85.
  final double minScale;

  /// Minimum opacity applied to non-centered slides. Default is 0.6.
  final double minOpacity;

  const DefaultSlideTransform({
    this.minScale = 0.85,
    this.minOpacity = 0.6,
  });

  @override
  Widget transform(
      BuildContext context, Widget child, AtrialTransformDetails details) {
    final double dist = details.position.abs().clamp(0.0, 1.0);
    final double scale = 1.0 - (1.0 - minScale) * dist;
    final double opacity = 1.0 - (1.0 - minOpacity) * dist;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: child,
      ),
    );
  }
}

/// 3D Cube rotation transition effect.
class CubeSlideTransform extends AtrialSlideTransform {
  /// Matrix perspective factor. Defaults to 0.0015.
  final double perspective;

  /// Whether to fade out slides as they rotate away. Defaults to true.
  final bool fade;

  const CubeSlideTransform({
    this.perspective = 0.0015,
    this.fade = true,
  });

  @override
  Widget transform(
      BuildContext context, Widget child, AtrialTransformDetails details) {
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
}

/// Accordion fold transition effect.
class AccordionSlideTransform extends AtrialSlideTransform {
  const AccordionSlideTransform();

  @override
  Widget transform(
      BuildContext context, Widget child, AtrialTransformDetails details) {
    final double pos = details.position;
    if (pos < -1.0 || pos > 1.0) {
      return const SizedBox.shrink();
    }

    final double scale = 1.0 - pos.abs();
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
}

/// Classic Zoom-Out page transition effect.
class ZoomOutSlideTransform extends AtrialSlideTransform {
  final double minScale;
  final double minAlpha;

  const ZoomOutSlideTransform({
    this.minScale = 0.85,
    this.minAlpha = 0.5,
  });

  @override
  Widget transform(
      BuildContext context, Widget child, AtrialTransformDetails details) {
    final double pos = details.position;
    if (pos < -1.0 || pos > 1.0) {
      return const SizedBox.shrink();
    }

    final double scaleFactor = math.max(minScale, 1.0 - pos.abs());
    final double alphaFactor = minAlpha +
        (scaleFactor - minScale) / (1.0 - minScale) * (1.0 - minAlpha);

    return Transform.scale(
      scale: scaleFactor,
      child: Opacity(
        opacity: alphaFactor.clamp(0.0, 1.0),
        child: child,
      ),
    );
  }
}

/// Depth transition where incoming slides slide over scaled-down fading outgoing slides.
class DepthSlideTransform extends AtrialSlideTransform {
  final double minScale;

  const DepthSlideTransform({
    this.minScale = 0.75,
  });

  @override
  Widget transform(
      BuildContext context, Widget child, AtrialTransformDetails details) {
    final double pos = details.position;
    if (pos < -1.0 || pos > 1.0) {
      return const SizedBox.shrink();
    }

    if (pos <= 0) {
      // Current page moving out to the left
      return child;
    } else {
      // Coming in from right
      final double scaleFactor = minScale + (1 - minScale) * (1 - pos);
      final double opacityFactor = (1 - pos).clamp(0.0, 1.0);

      return Transform.scale(
        scale: scaleFactor,
        child: Opacity(
          opacity: opacityFactor,
          child: child,
        ),
      );
    }
  }
}

/// Parallax transition effect that shifts content slightly opposite to the scroll direction.
class ParallaxSlideTransform extends AtrialSlideTransform {
  /// The factor determining the parallax speed (typically 0.2 to 0.5).
  final double parallaxFactor;

  const ParallaxSlideTransform({
    this.parallaxFactor = 0.35,
  });

  @override
  Widget transform(
      BuildContext context, Widget child, AtrialTransformDetails details) {
    final double pos = details.position;
    if (pos < -1.0 || pos > 1.0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double dimension = details.scrollDirection == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        final double offset = -pos * dimension * parallaxFactor;

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
}

/// 3D Flip transition effect around the center axis.
class FlipSlideTransform extends AtrialSlideTransform {
  final double perspective;

  const FlipSlideTransform({
    this.perspective = 0.002,
  });

  @override
  Widget transform(
      BuildContext context, Widget child, AtrialTransformDetails details) {
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
}

/// Modern Card Stack transition where adjacent cards tuck neatly behind.
class CardStackSlideTransform extends AtrialSlideTransform {
  final double scaleStep;
  final double offsetStep;

  const CardStackSlideTransform({
    this.scaleStep = 0.08,
    this.offsetStep = 18.0,
  });

  @override
  Widget transform(
      BuildContext context, Widget child, AtrialTransformDetails details) {
    final double pos = details.position;
    if (pos < -1.0 || pos > 1.0) {
      return const SizedBox.shrink();
    }

    if (pos <= 0) {
      return Transform.scale(
        scale: 1.0 + (pos * 0.1),
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
}

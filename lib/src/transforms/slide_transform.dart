import 'package:flutter/widgets.dart';

/// Details provided to [AtrialSlideTransform.transform] during carousel rendering.
class AtrialTransformDetails {
  /// The index of the item within the original data list (0 <= index < itemCount).
  final int index;

  /// The page index in the underlying [PageView].
  final int page;

  /// The relative position of the slide from center:
  /// - `0.0` means the slide is perfectly in center.
  /// - `-1.0` means one page to the left/top.
  /// - `1.0` means one page to the right/bottom.
  final double position;

  /// The direction in which the carousel scrolls.
  final Axis scrollDirection;

  /// The viewport fraction of the carousel.
  final double viewportFraction;

  const AtrialTransformDetails({
    required this.index,
    required this.page,
    required this.position,
    required this.scrollDirection,
    required this.viewportFraction,
  });
}

/// Abstract base class for custom carousel slide transition animations.
abstract class AtrialSlideTransform {
  const AtrialSlideTransform();

  /// Transforms the slide [child] widget based on [details].
  Widget transform(
      BuildContext context, Widget child, AtrialTransformDetails details);
}

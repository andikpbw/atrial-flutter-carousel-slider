import '../atrial_carousel_options.dart';
import 'package:flutter/widgets.dart';

/// The strategy used to enlarge the center item when
/// [AtrialCarouselOptions.enlargeCenterPage] is enabled.
enum CenterPageEnlargeStrategy {
  /// Enlarges the center item uniformly using [Transform.scale].
  scale,

  /// Adjusts the cross-axis size proportionally to the viewport.
  height,

  /// Enlarges the center item while aligning side items inward toward the center.
  zoom,
}

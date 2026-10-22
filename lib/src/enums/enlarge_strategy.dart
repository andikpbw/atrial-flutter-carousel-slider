/// The strategy used to enlarge the center item when [enlargeCenterPage] is enabled.
enum CenterPageEnlargeStrategy {
  /// Enlarges the center item using [Transform.scale].
  scale,

  /// Adjusts the height proportionally.
  height,

  /// Enlarges the item with center zoom alignment.
  zoom,
}

/// Indicates the reason for a page change in [AtrialCarouselSlider].
enum CarouselPageChangedReason {
  /// Page changed as a result of direct user drag or swipe interaction.
  manual,

  /// Page changed automatically by the auto-play timer.
  timed,

  /// Page changed programmatically via [AtrialCarouselController].
  controller,
}

# 1.0.2

- **Bug Fixes & Stability**:
  - Fixed `onPageChanged` reporting `CarouselPageChangedReason.controller` instead of `CarouselPageChangedReason.timed` during auto-play transitions.
  - Fixed multi-page programmatic animations (`animateToPage`) prematurely resetting change reason before reaching the destination slide.
  - Fixed auto-play in finite mode (`enableInfiniteScroll: false`) getting stuck on the final slide when `pauseAutoPlayInFiniteScroll` is `false` (now smoothly rewinds to index `0`).
  - Fixed `AtrialCarouselController.startAutoPlay()` not starting auto-play when `options.autoPlay` was initially `false`, and prevented hover/touch exit from restarting a manually stopped carousel.
  - Fixed `AtrialCarouselIndicator` vertical orientation (`axis: Axis.vertical`) layout sizing, rendering, and tap hit-testing.
  - Fixed infinite-loop wrap-around transition (`count - 1` → `0`) across all built-in indicator effects (`ExpandingDotsEffect`, `WormIndicatorEffect`, `SlideIndicatorEffect`, `ScaleIndicatorEffect`, `ColorTransitionEffect`).
  - Fixed `ZoomOutSlideTransform` potential `NaN` opacity error when `minScale == 1.0`.
  - Fixed dynamic `didUpdateWidget` updates when `itemCount`, `viewportFraction`, or `enableInfiniteScroll` changes at runtime (including async slide loading with `autoPlay: true`).
  - Fixed `CenterPageEnlargeStrategy.height` when using `aspectRatio` (`height == null`) and refined `CenterPageEnlargeStrategy.zoom` inward alignment.
- **Enhancements & Performance**:
  - Added `CoverFlowSlideTransform` 3D CoverFlow tilt transition.
  - Added `padEnds`, `allowImplicitScrolling`, and `pageViewKey` to `AtrialCarouselOptions`.
  - Added `currentOffset`, `isAutoPlaying`, and `isDisposed` getters plus safe controller lifecycle guards to `AtrialCarouselController`.
  - Added `RepaintBoundary` slide isolation and skipped per-frame `AnimatedBuilder` wrapper when neither `slideTransform` nor `enlargeCenterPage` is enabled.
  - Implemented value equality (`==` and `hashCode`) across `AtrialCarouselOptions`, `AtrialSlideTransform` implementations, and `AtrialIndicatorEffect` implementations to prevent redundant repaints.
  - Improved dot tap hit-testing precision for `ExpandingDotsEffect` and `ScaleIndicatorEffect`.

# 1.0.1

- Updated documentation and badges with [Humanize AI](https://humanize.id) sponsorship & support link.

# 1.0.0

- Initial release of **atrial_carousel_slider** 🎉
- Modern, performant, and highly customizable carousel slider widget for Flutter.
- Features:
  - Infinite looping and bounded scroll modes.
  - Smooth auto-play with pause-on-touch and pause-on-hover (desktop/web support).
  - Center page enlargement (`enlargeCenterPage`) with multiple enlarge strategies (`scale`, `height`, `zoom`).
  - Rich collection of built-in 3D and 2D slide transitions:
    - `CubeSlideTransform` (3D Cube rotation)
    - `ParallaxSlideTransform` (parallax depth movement)
    - `AccordionSlideTransform`
    - `ZoomOutSlideTransform`
    - `DepthSlideTransform`
    - `FlipSlideTransform` (3D card flip)
    - `CardStackSlideTransform`
    - Custom extensible `AtrialSlideTransform` interface.
  - Modern indicator widget (`AtrialCarouselIndicator`) with diverse animation effects:
    - `ExpandingDotsEffect`
    - `WormIndicatorEffect`
    - `SlideIndicatorEffect`
    - `ScaleIndicatorEffect`
    - `ColorTransitionEffect`
  - Fully featured programmatic controller (`AtrialCarouselController`) with:
    - `nextPage`, `previousPage`, `jumpToPage`, `animateToPage`
    - `startAutoPlay`, `stopAutoPlay`
    - `pageNotifier` and `scrollNotifier` listeners for real-time reactivity.
  - Zero external third-party dependencies (pure Flutter framework).
  - 100% test coverage and 0 lint warnings.

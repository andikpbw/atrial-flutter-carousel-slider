import 'package:flutter/widgets.dart';
import 'enums/carousel_page_changed_reason.dart';
import 'enums/enlarge_strategy.dart';
import 'transforms/slide_transform.dart';

/// Callback invoked when the current page changes.
typedef OnPageChangedCallback = void Function(
  int index,
  CarouselPageChangedReason reason,
);

/// Callback invoked continuously as the carousel is scrolled.
typedef OnScrolledCallback = void Function(double? offset);

/// Configuration options for [AtrialCarouselSlider].
class AtrialCarouselOptions {
  /// Fixed height for the carousel widget.
  ///
  /// If null, [aspectRatio] will be used instead.
  final double? height;

  /// Aspect ratio used to determine the height if [height] is not specified.
  /// Defaults to `16 / 9`.
  final double aspectRatio;

  /// The fraction of viewport that each slide occupies. Defaults to `0.85`.
  ///
  /// Setting this to `1.0` makes each slide fill the entire carousel width.
  final double viewportFraction;

  /// The initial page index when carousel is first created. Defaults to `0`.
  final int initialPage;

  /// Whether the carousel loops infinitely. Defaults to `true`.
  final bool enableInfiniteScroll;

  /// Whether to reverse the scroll direction. Defaults to `false`.
  final bool reverse;

  /// Whether the carousel should automatically scroll slides. Defaults to `false`.
  final bool autoPlay;

  /// The duration between each auto-play transition. Defaults to `4 seconds`.
  final Duration autoPlayInterval;

  /// The duration of the auto-play animation transition. Defaults to `800 milliseconds`.
  final Duration autoPlayAnimationDuration;

  /// The animation curve for auto-play transitions. Defaults to [Curves.fastOutSlowIn].
  final Curve autoPlayCurve;

  /// Whether to enlarge the center slide relative to side slides. Defaults to `true`.
  final bool enlargeCenterPage;

  /// How much smaller the side slides are compared to the center slide. Defaults to `0.2`.
  /// (e.g. `0.2` means side slides are 80% size of the center slide).
  final double enlargeFactor;

  /// Strategy used to enlarge the center slide. Defaults to [CenterPageEnlargeStrategy.scale].
  final CenterPageEnlargeStrategy enlargeStrategy;

  /// Optional custom slide transform effect (e.g. [CubeSlideTransform], [ParallaxSlideTransform], [AccordionSlideTransform]).
  final AtrialSlideTransform? slideTransform;

  /// Callback fired when the active page changes.
  final OnPageChangedCallback? onPageChanged;

  /// Callback fired continuously as the carousel is scrolled.
  final OnScrolledCallback? onScrolled;

  /// Scroll physics for the carousel. Defaults to [BouncingScrollPhysics].
  final ScrollPhysics? scrollPhysics;

  /// The axis along which the carousel scrolls. Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// Whether auto-play should pause when user touches or drags a slide. Defaults to `true`.
  final bool pauseAutoPlayOnTouch;

  /// Whether auto-play should pause when mouse cursor hovers over the carousel (desktop and web). Defaults to `true`.
  final bool pauseAutoPlayOnHover;

  /// Whether auto-play stops when reaching the last page if [enableInfiniteScroll] is false. Defaults to `false`.
  final bool pauseAutoPlayInFiniteScroll;

  /// Whether snapping to pages is enabled. Defaults to `true`.
  final bool pageSnapping;

  /// The clipping behavior for the carousel viewport. Defaults to [Clip.antiAlias].
  final Clip clipBehavior;

  /// Optional padding around the carousel viewport. Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry padding;

  /// Whether to animate to the closest page index when navigating in infinite mode. Defaults to `true`.
  final bool animateToClosest;

  const AtrialCarouselOptions({
    this.height,
    this.aspectRatio = 16 / 9,
    this.viewportFraction = 0.85,
    this.initialPage = 0,
    this.enableInfiniteScroll = true,
    this.reverse = false,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.autoPlayAnimationDuration = const Duration(milliseconds: 800),
    this.autoPlayCurve = Curves.fastOutSlowIn,
    this.enlargeCenterPage = true,
    this.enlargeFactor = 0.2,
    this.enlargeStrategy = CenterPageEnlargeStrategy.scale,
    this.slideTransform,
    this.onPageChanged,
    this.onScrolled,
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
    this.pauseAutoPlayOnTouch = true,
    this.pauseAutoPlayOnHover = true,
    this.pauseAutoPlayInFiniteScroll = false,
    this.pageSnapping = true,
    this.clipBehavior = Clip.antiAlias,
    this.padding = EdgeInsets.zero,
    this.animateToClosest = true,
  });

  /// Creates a copy of this [AtrialCarouselOptions] with the given fields replaced.
  AtrialCarouselOptions copyWith({
    double? height,
    double? aspectRatio,
    double? viewportFraction,
    int? initialPage,
    bool? enableInfiniteScroll,
    bool? reverse,
    bool? autoPlay,
    Duration? autoPlayInterval,
    Duration? autoPlayAnimationDuration,
    Curve? autoPlayCurve,
    bool? enlargeCenterPage,
    double? enlargeFactor,
    CenterPageEnlargeStrategy? enlargeStrategy,
    AtrialSlideTransform? slideTransform,
    OnPageChangedCallback? onPageChanged,
    OnScrolledCallback? onScrolled,
    ScrollPhysics? scrollPhysics,
    Axis? scrollDirection,
    bool? pauseAutoPlayOnTouch,
    bool? pauseAutoPlayOnHover,
    bool? pauseAutoPlayInFiniteScroll,
    bool? pageSnapping,
    Clip? clipBehavior,
    EdgeInsetsGeometry? padding,
    bool? animateToClosest,
  }) {
    return AtrialCarouselOptions(
      height: height ?? this.height,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      viewportFraction: viewportFraction ?? this.viewportFraction,
      initialPage: initialPage ?? this.initialPage,
      enableInfiniteScroll: enableInfiniteScroll ?? this.enableInfiniteScroll,
      reverse: reverse ?? this.reverse,
      autoPlay: autoPlay ?? this.autoPlay,
      autoPlayInterval: autoPlayInterval ?? this.autoPlayInterval,
      autoPlayAnimationDuration:
          autoPlayAnimationDuration ?? this.autoPlayAnimationDuration,
      autoPlayCurve: autoPlayCurve ?? this.autoPlayCurve,
      enlargeCenterPage: enlargeCenterPage ?? this.enlargeCenterPage,
      enlargeFactor: enlargeFactor ?? this.enlargeFactor,
      enlargeStrategy: enlargeStrategy ?? this.enlargeStrategy,
      slideTransform: slideTransform ?? this.slideTransform,
      onPageChanged: onPageChanged ?? this.onPageChanged,
      onScrolled: onScrolled ?? this.onScrolled,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      pauseAutoPlayOnTouch: pauseAutoPlayOnTouch ?? this.pauseAutoPlayOnTouch,
      pauseAutoPlayOnHover: pauseAutoPlayOnHover ?? this.pauseAutoPlayOnHover,
      pauseAutoPlayInFiniteScroll:
          pauseAutoPlayInFiniteScroll ?? this.pauseAutoPlayInFiniteScroll,
      pageSnapping: pageSnapping ?? this.pageSnapping,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      padding: padding ?? this.padding,
      animateToClosest: animateToClosest ?? this.animateToClosest,
    );
  }
}

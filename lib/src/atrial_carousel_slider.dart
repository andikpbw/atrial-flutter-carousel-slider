import 'dart:async';
import 'package:flutter/widgets.dart';
import 'atrial_carousel_controller.dart';
import 'atrial_carousel_options.dart';
import 'enums/carousel_page_changed_reason.dart';
import 'enums/enlarge_strategy.dart';
import 'transforms/slide_transform.dart';

const int _kInfiniteMultiplier = 10000;

/// A modern, feature-packed Flutter carousel slider widget.
class AtrialCarouselSlider extends StatefulWidget {
  /// The list of widgets to display in the carousel.
  final List<Widget>? items;

  /// Total count of items when using the builder constructor.
  final int itemCount;

  /// Widget builder function used to lazily construct carousel slides.
  final IndexedWidgetBuilder? itemBuilder;

  /// Carousel options and settings.
  final AtrialCarouselOptions options;

  /// Optional controller to programmatically drive the carousel.
  final AtrialCarouselController? controller;

  /// Creates a carousel slider from an explicit list of [items].
  const AtrialCarouselSlider({
    super.key,
    required List<Widget> items,
    AtrialCarouselOptions? options,
    this.controller,
  })  : items = items,
        itemCount = items.length,
        itemBuilder = null,
        options = options ?? const AtrialCarouselOptions();

  /// Creates a carousel slider that lazily creates slides using an [itemBuilder].
  const AtrialCarouselSlider.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    AtrialCarouselOptions? options,
    this.controller,
  })  : items = null,
        options = options ?? const AtrialCarouselOptions();

  @override
  State<AtrialCarouselSlider> createState() => _AtrialCarouselSliderState();
}

class _AtrialCarouselSliderState extends State<AtrialCarouselSlider>
    implements AtrialCarouselStateInterface {
  late PageController _pageController;
  Timer? _autoPlayTimer;
  late int _initialRealPage;
  int _currentActualPage = 0;
  CarouselPageChangedReason _lastChangeReason =
      CarouselPageChangedReason.manual;

  bool get _isInfinite =>
      widget.options.enableInfiniteScroll && widget.itemCount > 1;

  @override
  int get currentPage => _currentActualPage;

  @override
  double get currentOffset =>
      _pageController.hasClients ? (_pageController.page ?? 0.0) : 0.0;

  @override
  void initState() {
    super.initState();
    _currentActualPage = widget.options.initialPage;
    _computeInitialPage();
    _pageController = PageController(
      initialPage: _initialRealPage,
      viewportFraction: widget.options.viewportFraction,
    );

    widget.controller?.attach(this);
    widget.controller?.pageNotifier.value = _currentActualPage;

    if (widget.options.autoPlay) {
      _startTimer();
    }
  }

  void _computeInitialPage() {
    if (widget.itemCount <= 0) {
      _initialRealPage = 0;
      return;
    }
    final int safeInitial =
        widget.options.initialPage.clamp(0, widget.itemCount - 1);
    if (_isInfinite) {
      _initialRealPage =
          (_kInfiniteMultiplier ~/ 2) * widget.itemCount + safeInitial;
    } else {
      _initialRealPage = safeInitial;
    }
  }

  @override
  void didUpdateWidget(covariant AtrialCarouselSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      widget.controller?.attach(this);
      widget.controller?.pageNotifier.value = _currentActualPage;
    }

    if (oldWidget.options.autoPlay != widget.options.autoPlay ||
        oldWidget.options.autoPlayInterval != widget.options.autoPlayInterval) {
      if (widget.options.autoPlay) {
        _startTimer();
      } else {
        _stopTimer();
      }
    }
  }

  @override
  void dispose() {
    _stopTimer();
    widget.controller?.detach();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _stopTimer();
    if (!widget.options.autoPlay || widget.itemCount <= 1) return;

    _autoPlayTimer = Timer.periodic(widget.options.autoPlayInterval, (timer) {
      if (!mounted) return;
      if (!_isInfinite &&
          widget.options.pauseAutoPlayInFiniteScroll &&
          _currentActualPage >= widget.itemCount - 1) {
        _stopTimer();
        return;
      }
      _lastChangeReason = CarouselPageChangedReason.timed;
      nextPage(
        duration: widget.options.autoPlayAnimationDuration,
        curve: widget.options.autoPlayCurve,
      );
    });
  }

  void _stopTimer() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _onPointerDown() {
    if (widget.options.pauseAutoPlayOnTouch) {
      _stopTimer();
    }
  }

  void _onPointerUp() {
    if (widget.options.pauseAutoPlayOnTouch && widget.options.autoPlay) {
      _startTimer();
    }
  }

  void _onMouseEnter() {
    if (widget.options.pauseAutoPlayOnHover) {
      _stopTimer();
    }
  }

  void _onMouseExit() {
    if (widget.options.pauseAutoPlayOnHover && widget.options.autoPlay) {
      _startTimer();
    }
  }

  int _calculateTargetRealPage(int targetActualPage) {
    if (widget.itemCount == 0) return 0;
    final int safeTarget = targetActualPage.clamp(0, widget.itemCount - 1);
    if (!_isInfinite) {
      return safeTarget;
    }

    final int currentReal =
        _pageController.hasClients && _pageController.page != null
            ? _pageController.page!.round()
            : _initialRealPage;
    final int currentActual = currentReal % widget.itemCount;
    int diff = safeTarget - currentActual;

    if (widget.options.animateToClosest) {
      if (diff > widget.itemCount / 2) {
        diff -= widget.itemCount;
      } else if (diff < -widget.itemCount / 2) {
        diff += widget.itemCount;
      }
    }

    return currentReal + diff;
  }

  @override
  Future<void> nextPage({Duration? duration, Curve? curve}) async {
    if (!_pageController.hasClients || widget.itemCount <= 1) return;
    _lastChangeReason = CarouselPageChangedReason.controller;

    final int currentReal = _pageController.page?.round() ?? _initialRealPage;
    if (!_isInfinite && currentReal >= widget.itemCount - 1) {
      return;
    }

    await _pageController.nextPage(
      duration: duration ?? widget.options.autoPlayAnimationDuration,
      curve: curve ?? widget.options.autoPlayCurve,
    );
  }

  @override
  Future<void> previousPage({Duration? duration, Curve? curve}) async {
    if (!_pageController.hasClients || widget.itemCount <= 1) return;
    _lastChangeReason = CarouselPageChangedReason.controller;

    final int currentReal = _pageController.page?.round() ?? _initialRealPage;
    if (!_isInfinite && currentReal <= 0) {
      return;
    }

    await _pageController.previousPage(
      duration: duration ?? widget.options.autoPlayAnimationDuration,
      curve: curve ?? widget.options.autoPlayCurve,
    );
  }

  @override
  void jumpToPage(int page) {
    if (!_pageController.hasClients || widget.itemCount == 0) return;
    _lastChangeReason = CarouselPageChangedReason.controller;
    final int target = _calculateTargetRealPage(page);
    _pageController.jumpToPage(target);
  }

  @override
  Future<void> animateToPage(int page,
      {Duration? duration, Curve? curve}) async {
    if (!_pageController.hasClients || widget.itemCount == 0) return;
    _lastChangeReason = CarouselPageChangedReason.controller;
    final int target = _calculateTargetRealPage(page);
    await _pageController.animateToPage(
      target,
      duration: duration ?? widget.options.autoPlayAnimationDuration,
      curve: curve ?? widget.options.autoPlayCurve,
    );
  }

  @override
  void startAutoPlay() {
    _startTimer();
  }

  @override
  void stopAutoPlay() {
    _stopTimer();
  }

  Widget _buildSlide(BuildContext context, int realIndex) {
    if (widget.itemCount == 0) return const SizedBox.shrink();

    final int actualIndex = realIndex % widget.itemCount;
    final Widget rawItem = widget.itemBuilder != null
        ? widget.itemBuilder!(context, actualIndex)
        : widget.items![actualIndex];

    return AnimatedBuilder(
      animation: _pageController,
      child: rawItem,
      builder: (context, child) {
        double pageValue = _initialRealPage.toDouble();
        if (_pageController.hasClients &&
            _pageController.position.haveDimensions) {
          pageValue = _pageController.page ?? pageValue;
        }

        final double position = realIndex - pageValue;

        if (widget.options.slideTransform != null) {
          return widget.options.slideTransform!.transform(
            context,
            child!,
            AtrialTransformDetails(
              index: actualIndex,
              page: realIndex,
              position: position,
              scrollDirection: widget.options.scrollDirection,
              viewportFraction: widget.options.viewportFraction,
            ),
          );
        }

        if (widget.options.enlargeCenterPage) {
          final double dist = position.abs().clamp(0.0, 1.0);
          final double scale = 1.0 - (dist * widget.options.enlargeFactor);

          switch (widget.options.enlargeStrategy) {
            case CenterPageEnlargeStrategy.scale:
              return Transform.scale(
                scale: scale,
                child: child,
              );
            case CenterPageEnlargeStrategy.height:
              return Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: widget.options.height != null
                      ? widget.options.height! * scale
                      : null,
                  child: child,
                ),
              );
            case CenterPageEnlargeStrategy.zoom:
              return Transform.scale(
                scale: scale,
                alignment: Alignment.center,
                child: child,
              );
          }
        }

        return child!;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) {
      return const SizedBox.shrink();
    }

    final int effectiveItemCount = _isInfinite
        ? widget.itemCount * _kInfiniteMultiplier
        : widget.itemCount;

    Widget pageView = PageView.builder(
      controller: _pageController,
      scrollDirection: widget.options.scrollDirection,
      reverse: widget.options.reverse,
      physics: widget.options.scrollPhysics ?? const BouncingScrollPhysics(),
      pageSnapping: widget.options.pageSnapping,
      clipBehavior: widget.options.clipBehavior,
      itemCount: effectiveItemCount,
      itemBuilder: _buildSlide,
      onPageChanged: (int realIndex) {
        final int actualIndex = realIndex % widget.itemCount;
        if (actualIndex != _currentActualPage) {
          _currentActualPage = actualIndex;
          widget.controller?.pageNotifier.value = actualIndex;
          widget.options.onPageChanged?.call(actualIndex, _lastChangeReason);
        }
        _lastChangeReason = CarouselPageChangedReason.manual;
      },
    );

    pageView = NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollUpdateNotification) {
          if (_pageController.hasClients &&
              _pageController.position.haveDimensions) {
            final page = _pageController.page;
            widget.options.onScrolled?.call(page);
            if (page != null) {
              widget.controller?.scrollNotifier.value = page;
            }
          }
        }
        return false;
      },
      child: pageView,
    );

    pageView = Listener(
      onPointerDown: (_) => _onPointerDown(),
      onPointerUp: (_) => _onPointerUp(),
      onPointerCancel: (_) => _onPointerUp(),
      child: MouseRegion(
        onEnter: (_) => _onMouseEnter(),
        onExit: (_) => _onMouseExit(),
        child: pageView,
      ),
    );

    if (widget.options.padding != EdgeInsets.zero) {
      pageView = Padding(
        padding: widget.options.padding,
        child: pageView,
      );
    }

    if (widget.options.height != null) {
      return SizedBox(
        height: widget.options.height,
        child: pageView,
      );
    }

    return AspectRatio(
      aspectRatio: widget.options.aspectRatio,
      child: pageView,
    );
  }
}

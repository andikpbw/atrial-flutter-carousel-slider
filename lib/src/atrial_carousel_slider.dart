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
    required IndexedWidgetBuilder this.itemBuilder,
    AtrialCarouselOptions? options,
    this.controller,
  })  : assert(itemCount >= 0, 'itemCount cannot be negative'),
        items = null,
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

  bool _autoPlayEnabled = false;
  bool _isPointerDown = false;
  bool _isMouseHovered = false;
  int _activeProgrammaticAnimations = 0;
  CarouselPageChangedReason _lastChangeReason =
      CarouselPageChangedReason.manual;

  bool get _isInfinite =>
      widget.options.enableInfiniteScroll && widget.itemCount > 1;

  bool get _isInteractionPaused =>
      (_isPointerDown && widget.options.pauseAutoPlayOnTouch) ||
      (_isMouseHovered && widget.options.pauseAutoPlayOnHover);

  @override
  int get currentPage => _currentActualPage;

  @override
  double get currentOffset {
    if (_pageController.hasClients && _pageController.position.haveDimensions) {
      return _pageController.page ?? _initialRealPage.toDouble();
    }
    return _initialRealPage.toDouble();
  }

  @override
  bool get isAutoPlaying => _autoPlayTimer?.isActive ?? false;

  @override
  void initState() {
    super.initState();
    _autoPlayEnabled = widget.options.autoPlay;
    _currentActualPage = widget.itemCount > 0
        ? widget.options.initialPage.clamp(0, widget.itemCount - 1)
        : 0;
    _computeInitialPage(targetActualPage: _currentActualPage);
    _pageController = PageController(
      initialPage: _initialRealPage,
      viewportFraction: widget.options.viewportFraction,
    );

    _attachController(widget.controller);

    if (_autoPlayEnabled) {
      _startTimer();
    }
  }

  void _attachController(AtrialCarouselController? controller) {
    if (controller == null) return;
    controller.attach(this);
    controller.updatePage(_currentActualPage);
    controller.updateScroll(currentOffset);
  }

  void _computeInitialPage({int? targetActualPage}) {
    if (widget.itemCount <= 0) {
      _initialRealPage = 0;
      return;
    }
    final int safePage = (targetActualPage ?? widget.options.initialPage)
        .clamp(0, widget.itemCount - 1);
    if (_isInfinite) {
      _initialRealPage =
          (_kInfiniteMultiplier ~/ 2) * widget.itemCount + safePage;
    } else {
      _initialRealPage = safePage;
    }
  }

  @override
  void didUpdateWidget(covariant AtrialCarouselSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool oldIsInfinite =
        oldWidget.options.enableInfiniteScroll && oldWidget.itemCount > 1;
    final bool itemCountChanged = oldWidget.itemCount != widget.itemCount;
    final bool infiniteChanged = oldIsInfinite != _isInfinite;
    final bool viewportChanged =
        oldWidget.options.viewportFraction != widget.options.viewportFraction;

    if (widget.itemCount <= 0) {
      _currentActualPage = 0;
      _initialRealPage = 0;
    } else if (oldWidget.itemCount <= 0) {
      _currentActualPage =
          widget.options.initialPage.clamp(0, widget.itemCount - 1);
    } else if (_currentActualPage >= widget.itemCount) {
      _currentActualPage = widget.itemCount - 1;
    }

    if (viewportChanged || infiniteChanged || itemCountChanged) {
      _computeInitialPage(targetActualPage: _currentActualPage);
      _pageController.dispose();
      _pageController = PageController(
        initialPage: _initialRealPage,
        viewportFraction: widget.options.viewportFraction,
      );
      widget.controller?.updatePage(_currentActualPage);
      widget.controller?.updateScroll(_initialRealPage.toDouble());
    }

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach(this);
      _attachController(widget.controller);
    }

    if (oldWidget.options.autoPlay != widget.options.autoPlay) {
      _autoPlayEnabled = widget.options.autoPlay;
    }

    if (oldWidget.options.autoPlay != widget.options.autoPlay ||
        oldWidget.options.autoPlayInterval != widget.options.autoPlayInterval ||
        itemCountChanged ||
        infiniteChanged) {
      if (_autoPlayEnabled) {
        _startTimer();
      } else {
        _cancelTimer();
      }
    }
  }

  @override
  void dispose() {
    _cancelTimer();
    widget.controller?.detach(this);
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _cancelTimer();
    if (!_autoPlayEnabled || _isInteractionPaused || widget.itemCount <= 1) {
      return;
    }

    _autoPlayTimer = Timer.periodic(widget.options.autoPlayInterval, (_) {
      if (!mounted) return;
      _autoPlayNextPage();
    });
  }

  void _cancelTimer() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  Future<void> _runProgrammaticAnimation(
    CarouselPageChangedReason reason,
    Future<void> Function() action,
  ) async {
    _lastChangeReason = reason;
    _activeProgrammaticAnimations++;
    try {
      await action();
    } finally {
      _activeProgrammaticAnimations--;
      if (_activeProgrammaticAnimations == 0) {
        _lastChangeReason = CarouselPageChangedReason.manual;
      }
    }
  }

  Future<void> _autoPlayNextPage() async {
    if (!_pageController.hasClients || widget.itemCount <= 1) return;

    final int currentReal = _pageController.position.haveDimensions
        ? (_pageController.page?.round() ?? _initialRealPage)
        : _initialRealPage;

    if (!_isInfinite && currentReal >= widget.itemCount - 1) {
      if (widget.options.pauseAutoPlayInFiniteScroll) {
        _cancelTimer();
        return;
      }
      await _runProgrammaticAnimation(
        CarouselPageChangedReason.timed,
        () => _pageController.animateToPage(
          0,
          duration: widget.options.autoPlayAnimationDuration,
          curve: widget.options.autoPlayCurve,
        ),
      );
      return;
    }

    await _runProgrammaticAnimation(
      CarouselPageChangedReason.timed,
      () => _pageController.nextPage(
        duration: widget.options.autoPlayAnimationDuration,
        curve: widget.options.autoPlayCurve,
      ),
    );
  }

  void _onPointerDown() {
    _isPointerDown = true;
    if (_activeProgrammaticAnimations == 0) {
      _lastChangeReason = CarouselPageChangedReason.manual;
    }
    if (widget.options.pauseAutoPlayOnTouch) {
      _cancelTimer();
    }
  }

  void _onPointerUp() {
    _isPointerDown = false;
    if (widget.options.pauseAutoPlayOnTouch && _autoPlayEnabled) {
      _startTimer();
    }
  }

  void _onMouseEnter() {
    _isMouseHovered = true;
    if (widget.options.pauseAutoPlayOnHover) {
      _cancelTimer();
    }
  }

  void _onMouseExit() {
    _isMouseHovered = false;
    if (widget.options.pauseAutoPlayOnHover && _autoPlayEnabled) {
      _startTimer();
    }
  }

  int _calculateTargetRealPage(int targetActualPage) {
    if (widget.itemCount <= 0) return 0;
    final int safeTarget = targetActualPage.clamp(0, widget.itemCount - 1);
    if (!_isInfinite) {
      return safeTarget;
    }

    final int currentReal =
        _pageController.hasClients && _pageController.position.haveDimensions
            ? (_pageController.page?.round() ?? _initialRealPage)
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

    final int currentReal = _pageController.position.haveDimensions
        ? (_pageController.page?.round() ?? _initialRealPage)
        : _initialRealPage;
    if (!_isInfinite && currentReal >= widget.itemCount - 1) {
      return;
    }

    await _runProgrammaticAnimation(
      CarouselPageChangedReason.controller,
      () => _pageController.nextPage(
        duration: duration ?? widget.options.autoPlayAnimationDuration,
        curve: curve ?? widget.options.autoPlayCurve,
      ),
    );
  }

  @override
  Future<void> previousPage({Duration? duration, Curve? curve}) async {
    if (!_pageController.hasClients || widget.itemCount <= 1) return;

    final int currentReal = _pageController.position.haveDimensions
        ? (_pageController.page?.round() ?? _initialRealPage)
        : _initialRealPage;
    if (!_isInfinite && currentReal <= 0) {
      return;
    }

    await _runProgrammaticAnimation(
      CarouselPageChangedReason.controller,
      () => _pageController.previousPage(
        duration: duration ?? widget.options.autoPlayAnimationDuration,
        curve: curve ?? widget.options.autoPlayCurve,
      ),
    );
  }

  @override
  void jumpToPage(int page) {
    if (!_pageController.hasClients || widget.itemCount <= 0) return;
    final int target = _calculateTargetRealPage(page);
    _lastChangeReason = CarouselPageChangedReason.controller;
    _pageController.jumpToPage(target);
    widget.controller?.updateScroll(target.toDouble());
    if (_activeProgrammaticAnimations == 0) {
      _lastChangeReason = CarouselPageChangedReason.manual;
    }
  }

  @override
  Future<void> animateToPage(
    int page, {
    Duration? duration,
    Curve? curve,
  }) async {
    if (!_pageController.hasClients || widget.itemCount <= 0) return;
    final int target = _calculateTargetRealPage(page);
    await _runProgrammaticAnimation(
      CarouselPageChangedReason.controller,
      () => _pageController.animateToPage(
        target,
        duration: duration ?? widget.options.autoPlayAnimationDuration,
        curve: curve ?? widget.options.autoPlayCurve,
      ),
    );
  }

  @override
  void startAutoPlay() {
    _autoPlayEnabled = true;
    _startTimer();
  }

  @override
  void stopAutoPlay() {
    _autoPlayEnabled = false;
    _cancelTimer();
  }

  Widget _buildSlide(BuildContext context, int realIndex) {
    if (widget.itemCount <= 0) return const SizedBox.shrink();

    final int actualIndex = realIndex % widget.itemCount;
    final Widget rawItem = RepaintBoundary(
      child: widget.itemBuilder != null
          ? widget.itemBuilder!(context, actualIndex)
          : widget.items![actualIndex],
    );

    if (widget.options.slideTransform == null &&
        !widget.options.enlargeCenterPage) {
      return rawItem;
    }

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
          final double scale =
              (1.0 - (dist * widget.options.enlargeFactor)).clamp(0.0, 1.0);
          final bool isHorizontal =
              widget.options.scrollDirection == Axis.horizontal;

          switch (widget.options.enlargeStrategy) {
            case CenterPageEnlargeStrategy.scale:
              return Transform.scale(
                scale: scale,
                child: child,
              );
            case CenterPageEnlargeStrategy.height:
              return Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: isHorizontal ? 1.0 : scale,
                  heightFactor: isHorizontal ? scale : 1.0,
                  child: child,
                ),
              );
            case CenterPageEnlargeStrategy.zoom:
              final Alignment zoomAlignment = isHorizontal
                  ? (position > 0
                      ? Alignment.centerLeft
                      : (position < 0
                          ? Alignment.centerRight
                          : Alignment.center))
                  : (position > 0
                      ? Alignment.topCenter
                      : (position < 0
                          ? Alignment.bottomCenter
                          : Alignment.center));
              return Transform.scale(
                scale: scale,
                alignment: zoomAlignment,
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
    if (widget.itemCount <= 0) {
      return const SizedBox.shrink();
    }

    final int effectiveItemCount = _isInfinite
        ? widget.itemCount * _kInfiniteMultiplier
        : widget.itemCount;

    Widget pageView = PageView.builder(
      key: widget.options.pageViewKey,
      controller: _pageController,
      scrollDirection: widget.options.scrollDirection,
      reverse: widget.options.reverse,
      physics: widget.options.scrollPhysics ?? const BouncingScrollPhysics(),
      pageSnapping: widget.options.pageSnapping,
      padEnds: widget.options.padEnds,
      allowImplicitScrolling: widget.options.allowImplicitScrolling,
      clipBehavior: widget.options.clipBehavior,
      itemCount: effectiveItemCount,
      itemBuilder: _buildSlide,
      onPageChanged: (int realIndex) {
        final int actualIndex = realIndex % widget.itemCount;
        if (actualIndex != _currentActualPage) {
          _currentActualPage = actualIndex;
          widget.controller?.updatePage(actualIndex);
          widget.options.onPageChanged?.call(actualIndex, _lastChangeReason);
        }
      },
    );

    pageView = NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification &&
            notification.dragDetails != null) {
          _lastChangeReason = CarouselPageChangedReason.manual;
        } else if (notification is ScrollUpdateNotification) {
          if (_pageController.hasClients &&
              _pageController.position.haveDimensions) {
            final double? page = _pageController.page;
            widget.options.onScrolled?.call(page);
            if (page != null) {
              widget.controller?.updateScroll(page);
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

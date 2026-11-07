import 'dart:async';
import 'package:flutter/widgets.dart';
import 'atrial_carousel_slider.dart';

/// Contract for the state that can be controlled by [AtrialCarouselController].
abstract class AtrialCarouselStateInterface {
  /// Animates to the next slide.
  Future<void> nextPage({Duration? duration, Curve? curve});

  /// Animates to the previous slide.
  Future<void> previousPage({Duration? duration, Curve? curve});

  /// Jumps immediately to [page] without animation.
  void jumpToPage(int page);

  /// Animates to the specified [page].
  Future<void> animateToPage(int page, {Duration? duration, Curve? curve});

  /// Starts or resumes auto-play.
  void startAutoPlay();

  /// Stops or pauses auto-play.
  void stopAutoPlay();

  /// The active logical item index.
  int get currentPage;

  /// The continuous page offset reported by the underlying [PageController].
  double get currentOffset;

  /// Whether the auto-play timer is currently active.
  bool get isAutoPlaying;
}

/// A controller used to programmatically drive and observe an [AtrialCarouselSlider].
class AtrialCarouselController {
  AtrialCarouselStateInterface? _state;
  bool _isDisposed = false;

  /// Notifies listeners whenever the active slide index changes.
  final ValueNotifier<int> pageNotifier = ValueNotifier<int>(0);

  /// Notifies listeners continuously as the carousel is scrolled.
  final ValueNotifier<double> scrollNotifier = ValueNotifier<double>(0.0);

  /// Whether the controller is currently attached to a mounted [AtrialCarouselSlider].
  bool get isReady => !_isDisposed && _state != null;

  /// Whether [dispose] has been called on this controller.
  bool get isDisposed => _isDisposed;

  /// Returns the current active page index.
  int get currentPage => _state?.currentPage ?? pageNotifier.value;

  /// Returns the continuous scroll page offset.
  double get currentOffset => _state?.currentOffset ?? scrollNotifier.value;

  /// Whether auto-play is currently running on the attached carousel.
  bool get isAutoPlaying => _state?.isAutoPlaying ?? false;

  /// Attaches a state instance to this controller. Internal use only.
  void attach(AtrialCarouselStateInterface state) {
    if (_isDisposed) return;
    _state = state;
  }

  /// Detaches the state instance from this controller. Internal use only.
  ///
  /// If [state] is provided, detaches only when it matches the currently
  /// attached state instance.
  void detach([AtrialCarouselStateInterface? state]) {
    if (state == null || identical(_state, state)) {
      _state = null;
    }
  }

  /// Safely updates [pageNotifier] if this controller has not been disposed.
  /// Internal use only.
  void updatePage(int page) {
    if (_isDisposed) return;
    if (pageNotifier.value != page) {
      pageNotifier.value = page;
    }
  }

  /// Safely updates [scrollNotifier] if this controller has not been disposed.
  /// Internal use only.
  void updateScroll(double offset) {
    if (_isDisposed) return;
    if (scrollNotifier.value != offset) {
      scrollNotifier.value = offset;
    }
  }

  /// Animates the carousel to the next slide.
  Future<void> nextPage({Duration? duration, Curve? curve}) async {
    if (_isDisposed) return;
    await _state?.nextPage(duration: duration, curve: curve);
  }

  /// Animates the carousel to the previous slide.
  Future<void> previousPage({Duration? duration, Curve? curve}) async {
    if (_isDisposed) return;
    await _state?.previousPage(duration: duration, curve: curve);
  }

  /// Jumps immediately to the specified [page] without animation.
  void jumpToPage(int page) {
    if (_isDisposed) return;
    _state?.jumpToPage(page);
  }

  /// Animates the carousel to the specified [page].
  Future<void> animateToPage(
    int page, {
    Duration? duration,
    Curve? curve,
  }) async {
    if (_isDisposed) return;
    await _state?.animateToPage(page, duration: duration, curve: curve);
  }

  /// Resumes or starts auto-play.
  void startAutoPlay() {
    if (_isDisposed) return;
    _state?.startAutoPlay();
  }

  /// Pauses or stops auto-play.
  void stopAutoPlay() {
    if (_isDisposed) return;
    _state?.stopAutoPlay();
  }

  /// Disposes notifiers. Call this when the controller is no longer needed.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _state = null;
    pageNotifier.dispose();
    scrollNotifier.dispose();
  }
}

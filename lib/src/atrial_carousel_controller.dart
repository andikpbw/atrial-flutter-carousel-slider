import 'dart:async';
import 'package:flutter/widgets.dart';

/// Contract for the state that can be controlled by [AtrialCarouselController].
abstract class AtrialCarouselStateInterface {
  Future<void> nextPage({Duration? duration, Curve? curve});
  Future<void> previousPage({Duration? duration, Curve? curve});
  void jumpToPage(int page);
  Future<void> animateToPage(int page, {Duration? duration, Curve? curve});
  void startAutoPlay();
  void stopAutoPlay();
  int get currentPage;
  double get currentOffset;
}

/// A controller used to programmatically drive and observe an [AtrialCarouselSlider].
class AtrialCarouselController {
  AtrialCarouselStateInterface? _state;

  /// Notifies listeners whenever the active slide index changes.
  final ValueNotifier<int> pageNotifier = ValueNotifier<int>(0);

  /// Notifies listeners continuously as the carousel is scrolled.
  final ValueNotifier<double> scrollNotifier = ValueNotifier<double>(0.0);

  /// Whether the controller is currently attached to a mounted [AtrialCarouselSlider].
  bool get isReady => _state != null;

  /// Returns the current active page index.
  int get currentPage => _state?.currentPage ?? pageNotifier.value;

  /// Attaches a state instance to this controller. Internal use only.
  void attach(AtrialCarouselStateInterface state) {
    _state = state;
  }

  /// Detaches the state instance from this controller. Internal use only.
  void detach() {
    _state = null;
  }

  /// Animates the carousel to the next slide.
  Future<void> nextPage({Duration? duration, Curve? curve}) async {
    await _state?.nextPage(duration: duration, curve: curve);
  }

  /// Animates the carousel to the previous slide.
  Future<void> previousPage({Duration? duration, Curve? curve}) async {
    await _state?.previousPage(duration: duration, curve: curve);
  }

  /// Jumps immediately to the specified [page] without animation.
  void jumpToPage(int page) {
    _state?.jumpToPage(page);
  }

  /// Animates the carousel to the specified [page].
  Future<void> animateToPage(int page,
      {Duration? duration, Curve? curve}) async {
    await _state?.animateToPage(page, duration: duration, curve: curve);
  }

  /// Resumes or starts auto-play.
  void startAutoPlay() {
    _state?.startAutoPlay();
  }

  /// Pauses or stops auto-play.
  void stopAutoPlay() {
    _state?.stopAutoPlay();
  }

  /// Disposes notifiers. Call this when the controller is no longer needed.
  void dispose() {
    pageNotifier.dispose();
    scrollNotifier.dispose();
    _state = null;
  }
}

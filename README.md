# atrial_carousel_slider

[![pub package](https://img.shields.io/pub/v/atrial_carousel_slider.svg)](https://pub.dev/packages/atrial_carousel_slider)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/andikpbw/atrial-flutter-carousel-slider/blob/main/LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![platform](https://img.shields.io/badge/platform-android%20|%20ios%20|%20web%20|%20macos%20|%20windows%20|%20linux-blue.svg)](https://pub.dev/packages/atrial_carousel_slider)

A modern, high-performance, and feature-rich Flutter carousel slider widget with 3D transitions, parallax effects, autoplay, indicators, and rich programmatic control.

---

## ✨ Features

- 🚀 **Buttery Smooth Performance**: 60/120fps hardware-accelerated animations built directly on Flutter's core engine.
- 🔄 **Infinite Looping & Bounded Modes**: Seamless continuous infinite scroll with closest-direction animation logic.
- ⏱️ **Smart Auto-Play**: Automatically rotates slides, pauses on user interaction (touch/drag), and pauses on desktop/web mouse hover.
- 🎨 **Modern Slide Transitions**:
  - `CubeSlideTransform` (Stunning 3D cube rotation with perspective)
  - `ParallaxSlideTransform` (Smooth parallax depth)
  - `AccordionSlideTransform` (Accordion fold effect)
  - `ZoomOutSlideTransform` (Smooth scale & fade)
  - `DepthSlideTransform` (Depth tuck effect)
  - `FlipSlideTransform` (3D card flip)
  - `CardStackSlideTransform` (Modern stacked cards)
  - Extensible `AtrialSlideTransform` interface for custom transitions.
- 🔘 **Interactive Indicators (`AtrialCarouselIndicator`)**:
  - `ExpandingDotsEffect` (Popular dynamic expanding pill)
  - `WormIndicatorEffect` (Elastic worm stretch effect)
  - `SlideIndicatorEffect` (Sliding overlay dot)
  - `ScaleIndicatorEffect` (Smooth scale magnification)
  - `ColorTransitionEffect` (Color interpolation)
- 🎮 **Full Programmatic Controller (`AtrialCarouselController`)**:
  - `nextPage()`, `previousPage()`, `jumpToPage()`, `animateToPage()`
  - `startAutoPlay()`, `stopAutoPlay()`
  - `pageNotifier` & `scrollNotifier` `ValueNotifier`s for zero-boilerplate reactive UI.
- 📦 **Zero External Dependencies**: Pure Flutter framework. Compatible with iOS, Android, Web, macOS, Windows, and Linux.

---

## 📦 Installation

Add `atrial_carousel_slider` to your `pubspec.yaml`:

```yaml
dependencies:
  atrial_carousel_slider: ^1.0.0
```

Or install it directly via CLI:

```bash
flutter pub add atrial_carousel_slider
```

Then import it into your Dart file:

```dart
import 'package:atrial_carousel_slider/atrial_carousel_slider.dart';
```

---

## 🚀 Quick Start

### 1. Basic Carousel

```dart
import 'package:flutter/material.dart';
import 'package:atrial_carousel_slider/atrial_carousel_slider.dart';

class BasicCarouselDemo extends StatelessWidget {
  const BasicCarouselDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return AtrialCarouselSlider(
      items: [
        _buildSlide(Colors.indigo, 'Slide 1'),
        _buildSlide(Colors.teal, 'Slide 2'),
        _buildSlide(Colors.deepOrange, 'Slide 3'),
      ],
      options: const AtrialCarouselOptions(
        height: 200,
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 4),
        viewportFraction: 0.85,
      ),
    );
  }

  Widget _buildSlide(Color color, String text) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
```

---

### 2. Builder Pattern with Interactive Expanding Indicator

```dart
import 'package:flutter/material.dart';
import 'package:atrial_carousel_slider/atrial_carousel_slider.dart';

class IndicatorCarouselDemo extends StatefulWidget {
  const IndicatorCarouselDemo({super.key});

  @override
  State<IndicatorCarouselDemo> createState() => _IndicatorCarouselDemoState();
}

class _IndicatorCarouselDemoState extends State<IndicatorCarouselDemo> {
  final AtrialCarouselController _controller = AtrialCarouselController();
  final List<String> _items = ['Card A', 'Card B', 'Card C', 'Card D'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AtrialCarouselSlider.builder(
          controller: _controller,
          itemCount: _items.length,
          options: const AtrialCarouselOptions(
            height: 180,
            enlargeCenterPage: true,
            autoPlay: true,
            viewportFraction: 0.88,
          ),
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Text(_items[index], style: const TextStyle(fontSize: 22)),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        AtrialCarouselIndicator(
          controller: _controller,
          count: _items.length,
          effect: const ExpandingDotsEffect(
            activeDotColor: Colors.deepPurple,
            dotColor: Colors.grey,
            expansionFactor: 3.0,
            dotWidth: 8,
            dotHeight: 8,
          ),
          onDotClicked: (index) => _controller.animateToPage(index),
        ),
      ],
    );
  }
}
```

---

## 🎨 Built-in Slide Transforms

Easily switch visual transitions using the `slideTransform` property in `AtrialCarouselOptions`:

### 3D Cube Transform
```dart
AtrialCarouselOptions(
  slideTransform: const CubeSlideTransform(),
  viewportFraction: 0.85,
)
```

### Parallax Transform
```dart
AtrialCarouselOptions(
  slideTransform: const ParallaxSlideTransform(parallaxFactor: 0.35),
  viewportFraction: 0.85,
)
```

### 3D Flip Transform
```dart
AtrialCarouselOptions(
  slideTransform: const FlipSlideTransform(),
  viewportFraction: 0.85,
)
```

### Zoom-Out Transform
```dart
AtrialCarouselOptions(
  slideTransform: const ZoomOutSlideTransform(minScale: 0.8, minAlpha: 0.6),
  viewportFraction: 0.85,
)
```

### Accordion Fold Transform
```dart
AtrialCarouselOptions(
  slideTransform: const AccordionSlideTransform(),
  viewportFraction: 0.85,
)
```

---

## 🎮 Programmatic Controller (`AtrialCarouselController`)

```dart
final AtrialCarouselController controller = AtrialCarouselController();

// Navigate
controller.nextPage();
controller.previousPage();
controller.jumpToPage(2);
controller.animateToPage(3, duration: const Duration(milliseconds: 600));

// Control AutoPlay
controller.startAutoPlay();
controller.stopAutoPlay();

// Read states
int current = controller.currentPage;
bool ready = controller.isReady;

// Listen to page changes
controller.pageNotifier.addListener(() {
  print('Current page: ${controller.pageNotifier.value}');
});
```

---

## ⚙️ Options Reference (`AtrialCarouselOptions`)

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `height` | `double?` | `null` | Fixed height. If null, uses `aspectRatio`. |
| `aspectRatio` | `double` | `16 / 9` | Aspect ratio of the carousel. |
| `viewportFraction` | `double` | `0.85` | Fraction of the viewport occupied by each slide. |
| `initialPage` | `int` | `0` | Initial page index. |
| `enableInfiniteScroll` | `bool` | `true` | Enables continuous infinite looping. |
| `reverse` | `bool` | `false` | Reverses scroll direction. |
| `autoPlay` | `bool` | `false` | Enables automatic slide transitions. |
| `autoPlayInterval` | `Duration` | `4s` | Delay between auto transitions. |
| `autoPlayAnimationDuration` | `Duration` | `800ms` | Duration of the slide transition animation. |
| `autoPlayCurve` | `Curve` | `Curves.fastOutSlowIn` | Animation curve for auto transitions. |
| `enlargeCenterPage` | `bool` | `true` | Highlights the center slide relative to side items. |
| `enlargeFactor` | `double` | `0.2` | Scaling factor for side items (0.0 to 1.0). |
| `enlargeStrategy` | `CenterPageEnlargeStrategy` | `scale` | Strategy: `scale`, `height`, or `zoom`. |
| `slideTransform` | `AtrialSlideTransform?` | `null` | Custom 2D or 3D transform effect. |
| `onPageChanged` | `Function(index, reason)?` | `null` | Callback triggered when active page changes. |
| `onScrolled` | `Function(offset)?` | `null` | Callback triggered continuously during scrolling. |
| `scrollPhysics` | `ScrollPhysics?` | `BouncingScrollPhysics` | Custom scroll physics. |
| `scrollDirection` | `Axis` | `Axis.horizontal` | Scroll axis (`horizontal` or `vertical`). |
| `pauseAutoPlayOnTouch` | `bool` | `true` | Pauses auto-play while touching/dragging. |
| `pauseAutoPlayOnHover` | `bool` | `true` | Pauses auto-play on mouse hover (desktop/web). |
| `pageSnapping` | `bool` | `true` | Enables page snapping. |
| `animateToClosest` | `bool` | `true` | Animates along the shortest path in infinite mode. |

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atrial_carousel_slider/atrial_carousel_slider.dart';

void main() {
  testWidgets('renders indicator with various effects without crash',
      (WidgetTester tester) async {
    final List<AtrialIndicatorEffect> effects = [
      const ExpandingDotsEffect(),
      const WormIndicatorEffect(),
      const SlideIndicatorEffect(),
      const ScaleIndicatorEffect(),
      const ColorTransitionEffect(),
    ];

    for (final effect in effects) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AtrialCarouselIndicator.builder(
              count: 4,
              currentIndex: 1,
              effect: effect,
            ),
          ),
        ),
      );

      expect(find.byType(AtrialCarouselIndicator), findsOneWidget);
    }
  });

  testWidgets('taps on indicator trigger onDotClicked callback',
      (WidgetTester tester) async {
    int clickedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AtrialCarouselIndicator.builder(
              count: 4,
              currentIndex: 0,
              effect: const SlideIndicatorEffect(dotWidth: 20, spacing: 10),
              onDotClicked: (index) {
                clickedIndex = index;
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AtrialCarouselIndicator));
    await tester.pumpAndSettle();

    expect(clickedIndex, isNonNegative);
  });
}

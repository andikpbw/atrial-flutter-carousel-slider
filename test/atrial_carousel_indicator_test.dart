import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atrial_carousel_slider/atrial_carousel_slider.dart';

void main() {
  testWidgets(
      'renders indicator with all effects including wrap-around progress',
      (WidgetTester tester) async {
    final List<AtrialIndicatorEffect> effects = [
      const ExpandingDotsEffect(),
      const WormIndicatorEffect(),
      const SlideIndicatorEffect(),
      const ScaleIndicatorEffect(),
      const ColorTransitionEffect(paintStyle: PaintingStyle.stroke),
    ];

    final AtrialCarouselController controller = AtrialCarouselController();
    // Simulate infinite wrap-around midpoint between dot 3 and dot 0
    controller.updateScroll(3.5);

    for (final effect in effects) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AtrialCarouselIndicator(
              count: 4,
              controller: controller,
              effect: effect,
            ),
          ),
        ),
      );

      expect(find.byType(AtrialCarouselIndicator), findsOneWidget);
    }

    controller.dispose();
  });

  testWidgets('taps on horizontal ExpandingDotsEffect resolve exact dot index',
      (WidgetTester tester) async {
    int clickedIndex = -1;
    const effect = ExpandingDotsEffect(
      dotWidth: 10,
      dotHeight: 10,
      spacing: 10,
      expansionFactor: 3.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: AtrialCarouselIndicator.builder(
              count: 4,
              currentIndex: 0,
              padding: EdgeInsets.zero,
              effect: effect,
              onDotClicked: (index) {
                clickedIndex = index;
              },
            ),
          ),
        ),
      ),
    );

    // Dot 0 is [0..30], spacing [30..40], Dot 1 is [40..50], Dot 3 is [80..90]
    await tester.tapAt(const Offset(45, 5));
    await tester.pump();
    expect(clickedIndex, 1);

    await tester.tapAt(const Offset(85, 5));
    await tester.pump();
    expect(clickedIndex, 3);
  });

  testWidgets('supports Axis.vertical layout and vertical tap hit-testing',
      (WidgetTester tester) async {
    int clickedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: AtrialCarouselIndicator.builder(
              count: 4,
              currentIndex: 0,
              axis: Axis.vertical,
              padding: EdgeInsets.zero,
              effect: const SlideIndicatorEffect(
                dotWidth: 20,
                dotHeight: 10,
                spacing: 10,
              ),
              onDotClicked: (index) {
                clickedIndex = index;
              },
            ),
          ),
        ),
      ),
    );

    final Size size = tester.getSize(find.byType(AtrialCarouselIndicator));
    // Vertical size swaps width (10) and height (4*20 + 3*10 = 110)
    expect(size.width, 10.0);
    expect(size.height, 110.0);

    // Tap near top -> dot 0
    await tester.tapAt(const Offset(5, 8));
    await tester.pump();
    expect(clickedIndex, 0);

    // Tap near bottom -> dot 3
    await tester.tapAt(const Offset(5, 102));
    await tester.pump();
    expect(clickedIndex, 3);
  });
}

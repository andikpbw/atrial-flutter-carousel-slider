import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atrial_carousel_slider/atrial_carousel_slider.dart';

void main() {
  testWidgets('transforms execute and produce valid widget subtree',
      (WidgetTester tester) async {
    final List<AtrialSlideTransform> transforms = [
      const DefaultSlideTransform(),
      const CubeSlideTransform(),
      const AccordionSlideTransform(),
      const ZoomOutSlideTransform(),
      const DepthSlideTransform(),
      const ParallaxSlideTransform(),
      const FlipSlideTransform(),
      const CardStackSlideTransform(),
    ];

    for (final transform in transforms) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AtrialCarouselSlider(
              items: [
                Container(
                    key: const ValueKey('slide_1'), child: const Text('A')),
                Container(
                    key: const ValueKey('slide_2'), child: const Text('B')),
              ],
              options: AtrialCarouselOptions(
                slideTransform: transform,
                viewportFraction: 0.8,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AtrialCarouselSlider), findsOneWidget);
    }
  });
}

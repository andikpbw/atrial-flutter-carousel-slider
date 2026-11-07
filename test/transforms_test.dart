import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atrial_carousel_slider/atrial_carousel_slider.dart';

void main() {
  testWidgets('all built-in transforms execute cleanly in both axes',
      (WidgetTester tester) async {
    final List<AtrialSlideTransform> transforms = [
      const DefaultSlideTransform(),
      const CubeSlideTransform(),
      const AccordionSlideTransform(),
      const ZoomOutSlideTransform(),
      const ZoomOutSlideTransform(minScale: 1.0),
      const DepthSlideTransform(),
      const ParallaxSlideTransform(),
      const FlipSlideTransform(),
      const CardStackSlideTransform(),
      const CoverFlowSlideTransform(),
    ];

    for (final axis in Axis.values) {
      for (final transform in transforms) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AtrialCarouselSlider(
                items: [
                  Container(
                    key: const ValueKey('slide_1'),
                    child: const Text('A'),
                  ),
                  Container(
                    key: const ValueKey('slide_2'),
                    child: const Text('B'),
                  ),
                ],
                options: AtrialCarouselOptions(
                  height: 200,
                  scrollDirection: axis,
                  slideTransform: transform,
                  viewportFraction: 0.8,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(AtrialCarouselSlider), findsOneWidget);
      }
    }
  });
}

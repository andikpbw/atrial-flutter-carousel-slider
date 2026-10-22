import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atrial_carousel_slider/atrial_carousel_slider.dart';

void main() {
  testWidgets('renders items properly with basic constructor',
      (WidgetTester tester) async {
    final List<Widget> items = List.generate(
      4,
      (i) => Container(
        key: ValueKey('item_$i'),
        child: Text('Slide $i'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AtrialCarouselSlider(
            items: items,
            options: const AtrialCarouselOptions(
              viewportFraction: 1.0,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Slide 0'), findsOneWidget);
  });

  testWidgets('renders items with builder constructor',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AtrialCarouselSlider.builder(
            itemCount: 5,
            itemBuilder: (context, index) => Container(
              key: ValueKey('item_$index'),
              child: Text('Builder Slide $index'),
            ),
            options: const AtrialCarouselOptions(
              viewportFraction: 1.0,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Builder Slide 0'), findsOneWidget);
  });

  testWidgets('handles empty items without errors',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AtrialCarouselSlider(
            items: const [],
          ),
        ),
      ),
    );

    expect(find.byType(AtrialCarouselSlider), findsOneWidget);
  });

  testWidgets('handles single item without infinite loop errors',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AtrialCarouselSlider(
            items: const [
              Text('Single Item'),
            ],
            options: const AtrialCarouselOptions(
              enableInfiniteScroll: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Single Item'), findsOneWidget);
  });

  testWidgets('enlargeCenterPage applies transform to center item',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AtrialCarouselSlider(
            items: List.generate(
              3,
              (i) => SizedBox(
                width: 300,
                height: 200,
                child: Text('Slide $i'),
              ),
            ),
            options: const AtrialCarouselOptions(
              enlargeCenterPage: true,
              enlargeFactor: 0.3,
              viewportFraction: 0.8,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Slide 0'), findsOneWidget);
    expect(find.byType(Transform), findsWidgets);
  });

  testWidgets('custom slideTransform is invoked', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AtrialCarouselSlider(
            items: const [
              Text('Slide 1'),
              Text('Slide 2'),
            ],
            options: const AtrialCarouselOptions(
              slideTransform: CubeSlideTransform(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Slide 1'), findsOneWidget);
  });
}

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

  testWidgets('handles empty items and out-of-range initialPage safely',
      (WidgetTester tester) async {
    final AtrialCarouselController controller = AtrialCarouselController();

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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AtrialCarouselSlider(
            controller: controller,
            items: const [Text('A'), Text('B'), Text('C')],
            options: const AtrialCarouselOptions(
              initialPage: 99,
              viewportFraction: 1.0,
            ),
          ),
        ),
      ),
    );

    expect(controller.currentPage, 2);
    expect(find.text('C'), findsOneWidget);
    controller.dispose();
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

  testWidgets(
      'enlargeCenterPage supports scale, height (aspectRatio), and zoom',
      (WidgetTester tester) async {
    for (final strategy in CenterPageEnlargeStrategy.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AtrialCarouselSlider(
              items: List.generate(
                3,
                (i) => Container(
                  color: Colors.blue,
                  child: Text('Slide $i'),
                ),
              ),
              options: AtrialCarouselOptions(
                enlargeCenterPage: true,
                enlargeStrategy: strategy,
                enlargeFactor: 0.3,
                viewportFraction: 0.8,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Slide 0'), findsOneWidget);
    }
  });

  testWidgets('autoPlay emits CarouselPageChangedReason.timed',
      (WidgetTester tester) async {
    final List<CarouselPageChangedReason> reasons = [];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AtrialCarouselSlider(
            items: const [
              Text('Slide 0'),
              Text('Slide 1'),
              Text('Slide 2'),
            ],
            options: AtrialCarouselOptions(
              autoPlay: true,
              autoPlayInterval: const Duration(milliseconds: 300),
              autoPlayAnimationDuration: const Duration(milliseconds: 100),
              viewportFraction: 1.0,
              onPageChanged: (_, reason) => reasons.add(reason),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(reasons, contains(CarouselPageChangedReason.timed));
    expect(reasons, isNot(contains(CarouselPageChangedReason.controller)));
  });

  testWidgets(
      'finite autoPlay wraps to page 0 or stops with pauseAutoPlayInFiniteScroll',
      (WidgetTester tester) async {
    final List<int> pages = [];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AtrialCarouselSlider(
            items: const [Text('P0'), Text('P1')],
            options: AtrialCarouselOptions(
              enableInfiniteScroll: false,
              pauseAutoPlayInFiniteScroll: false,
              autoPlay: true,
              autoPlayInterval: const Duration(milliseconds: 250),
              autoPlayAnimationDuration: const Duration(milliseconds: 80),
              viewportFraction: 1.0,
              onPageChanged: (index, _) => pages.add(index),
            ),
          ),
        ),
      ),
    );

    // Tick 1: 0 -> 1
    await tester.pump(const Duration(milliseconds: 260));
    await tester.pump(const Duration(milliseconds: 100));
    // Tick 2: 1 -> 0 (wraps around!)
    await tester.pump(const Duration(milliseconds: 260));
    await tester.pump(const Duration(milliseconds: 100));

    expect(pages, equals([1, 0]));
  });

  testWidgets('didUpdateWidget handles dynamic itemCount and viewportFraction',
      (WidgetTester tester) async {
    List<Widget> slides = const [];
    double fraction = 0.85;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  AtrialCarouselSlider(
                    items: slides,
                    options: AtrialCarouselOptions(
                      height: 150,
                      autoPlay: true,
                      autoPlayInterval: const Duration(milliseconds: 200),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 80),
                      viewportFraction: fraction,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        slides = const [Text('Loaded 0'), Text('Loaded 1')];
                        fraction = 1.0;
                      });
                    },
                    child: const Text('Load'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    expect(find.text('Loaded 0'), findsNothing);

    await tester.tap(find.text('Load'));
    await tester.pump();
    expect(find.text('Loaded 0'), findsOneWidget);

    // Auto-play starts automatically after async items load
    await tester.pump(const Duration(milliseconds: 220));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Loaded 1'), findsOneWidget);
  });

  test('AtrialCarouselOptions copyWith and equality work properly', () {
    const a = AtrialCarouselOptions(
      height: 200,
      viewportFraction: 0.9,
      padEnds: false,
    );
    final b = a.copyWith();
    final c = a.copyWith(padEnds: true);

    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
    expect(a, isNot(equals(c)));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atrial_carousel_slider/atrial_carousel_slider.dart';

void main() {
  testWidgets('controller animates, jumps, and reports accurate reasons',
      (WidgetTester tester) async {
    final AtrialCarouselController controller = AtrialCarouselController();
    final List<(int, CarouselPageChangedReason)> events = [];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AtrialCarouselSlider(
            controller: controller,
            items: List.generate(
              5,
              (i) => SizedBox(
                width: 300,
                height: 200,
                child: Text('Slide $i'),
              ),
            ),
            options: AtrialCarouselOptions(
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) => events.add((index, reason)),
            ),
          ),
        ),
      ),
    );

    expect(controller.isReady, isTrue);
    expect(controller.currentPage, 0);

    // Multi-page animateToPage reports controller reason for every crossed page
    final Future<void> animFuture = controller.animateToPage(
      3,
      duration: const Duration(milliseconds: 150),
    );
    await tester.pumpAndSettle();
    await animFuture;
    expect(controller.currentPage, 3);
    expect(
      events.every((e) => e.$2 == CarouselPageChangedReason.controller),
      isTrue,
    );

    // Jump to page 1
    controller.jumpToPage(1);
    await tester.pumpAndSettle();
    expect(controller.currentPage, 1);
    expect(find.text('Slide 1'), findsOneWidget);

    // Next & previous page
    final Future<void> nextFuture =
        controller.nextPage(duration: const Duration(milliseconds: 80));
    await tester.pumpAndSettle();
    await nextFuture;
    expect(controller.currentPage, 2);

    final Future<void> prevFuture =
        controller.previousPage(duration: const Duration(milliseconds: 80));
    await tester.pumpAndSettle();
    await prevFuture;
    expect(controller.currentPage, 1);

    controller.dispose();
    expect(controller.isDisposed, isTrue);
    expect(controller.isReady, isFalse);
  });

  testWidgets(
      'controller startAutoPlay works even when options.autoPlay is initially false',
      (WidgetTester tester) async {
    final AtrialCarouselController controller = AtrialCarouselController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AtrialCarouselSlider(
            controller: controller,
            items: const [Text('S0'), Text('S1'), Text('S2')],
            options: const AtrialCarouselOptions(
              autoPlay: false,
              autoPlayInterval: Duration(milliseconds: 200),
              autoPlayAnimationDuration: Duration(milliseconds: 80),
              viewportFraction: 1.0,
            ),
          ),
        ),
      ),
    );

    expect(controller.isAutoPlaying, isFalse);

    controller.startAutoPlay();
    expect(controller.isAutoPlaying, isTrue);

    await tester.pump(const Duration(milliseconds: 220));
    await tester.pump(const Duration(milliseconds: 100));
    expect(controller.currentPage, 1);

    controller.stopAutoPlay();
    expect(controller.isAutoPlaying, isFalse);

    controller.dispose();
  });

  testWidgets('controller pageNotifier emits on page change',
      (WidgetTester tester) async {
    final AtrialCarouselController controller = AtrialCarouselController();
    int notifiedIndex = -1;
    controller.pageNotifier.addListener(() {
      notifiedIndex = controller.pageNotifier.value;
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AtrialCarouselSlider(
            controller: controller,
            items: List.generate(
              4,
              (i) => SizedBox(
                width: 300,
                height: 200,
                child: Text('Item $i'),
              ),
            ),
            options: const AtrialCarouselOptions(
              viewportFraction: 1.0,
            ),
          ),
        ),
      ),
    );

    controller.jumpToPage(1);
    await tester.pumpAndSettle();
    expect(notifiedIndex, 1);

    controller.dispose();
  });
}

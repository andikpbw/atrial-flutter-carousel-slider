import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atrial_carousel_slider/atrial_carousel_slider.dart';

void main() {
  testWidgets('controller animates and jumps to pages',
      (WidgetTester tester) async {
    final AtrialCarouselController controller = AtrialCarouselController();

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
            options: const AtrialCarouselOptions(
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
            ),
          ),
        ),
      ),
    );

    expect(controller.isReady, isTrue);
    expect(controller.currentPage, 0);

    // Jump to page 2
    controller.jumpToPage(2);
    await tester.pumpAndSettle();
    expect(controller.currentPage, 2);
    expect(find.text('Slide 2'), findsOneWidget);

    // Next page
    controller.nextPage(duration: const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(controller.currentPage, 3);
    expect(find.text('Slide 3'), findsOneWidget);

    // Previous page
    controller.previousPage(duration: const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(controller.currentPage, 2);
    expect(find.text('Slide 2'), findsOneWidget);

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

import 'package:flutter_test/flutter_test.dart';
import 'package:starholme/round/tours.dart';

import 'support/fonts.dart';
import 'support/holmering.dart';

/// The holme, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the holme lists every tour by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Starholme'), findsOneWidget);
    for (final tour in Tours.all) {
      expect(find.text(tour.name), findsOneWidget);
      expect(
        find.textContaining(tour.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a tour opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Pentagon'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap post after post along the lanes'),
      findsOneWidget,
    );
  });

  testWidgets('a closing writes its fewest onto the holme',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Pentagon'));
    await tester.pumpAndSettle();
    await walkRound(tester, const [0, 1, 2, 3, 4]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The holme');
    expect(find.textContaining('Fewest: 6'), findsOneWidget);
  });
}

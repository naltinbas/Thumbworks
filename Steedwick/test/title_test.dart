import 'package:flutter_test/flutter_test.dart';
import 'package:steedwick/paddock/errands.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every errand by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Steedwick'), findsOneWidget);
    for (final errand in Errands.all) {
      expect(find.text(errand.name), findsOneWidget);
      expect(
        find.textContaining(errand.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('an errand opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Errand'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a steed, then an empty stall'),
      findsOneWidget,
    );
  });

  testWidgets('a ridden errand writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Errand'));
    await tester.pumpAndSettle();
    await ride(tester, 2, 1);
    await ride(tester, 0, 5);
    await ride(tester, 0, 6);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}

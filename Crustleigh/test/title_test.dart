import 'package:flutter_test/flutter_test.dart';
import 'package:crustleigh/show/levels.dart';

import 'support/fonts.dart';
import 'support/showland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every show by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Crustleigh'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a show opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Ring'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a pie to move it up its judge\'s card'),
      findsOneWidget,
    );
  });

  testWidgets('a judging writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Ring'));
    await tester.pumpAndSettle();
    await setBallot(tester, 1, [1, 2, 0]);
    await setBallot(tester, 2, [2, 0, 1]);
    expect(state(tester).play.isDone, isTrue);
    final moves = state(tester).play.moves;
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: $moves'), findsOneWidget);
  });
}

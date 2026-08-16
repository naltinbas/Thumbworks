import 'package:flutter_test/flutter_test.dart';
import 'package:ladderby/join/levels.dart';

import 'support/fonts.dart';
import 'support/joinland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Ladderby'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Middle Rung'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap three pegs on each rail and the six cross-joins are drawn'),
      findsOneWidget,
    );
  });

  testWidgets('a hexagon writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Middle Rung'));
    await tester.pumpAndSettle();
    await setPegs(tester, [0, 1, 2], [0, 1, 2]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 6'), findsOneWidget);
  });
}

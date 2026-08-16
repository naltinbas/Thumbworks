import 'package:flutter_test/flutter_test.dart';
import 'package:cornerwick/square/levels.dart';

import 'support/fonts.dart';
import 'support/boardland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Cornerwick'), findsOneWidget);
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
    await tester.tap(find.text('The Whole Centres'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap four pegs in order and a square is built outward'),
      findsOneWidget,
    );
  });

  testWidgets('a four writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Whole Centres'));
    await tester.pumpAndSettle();
    await setPegs(tester, [(1, 1), (3, 1), (3, 3), (1, 3)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:beamsley/shadow/levels.dart';

import 'support/fonts.dart';
import 'support/lanternland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Beamsley'), findsOneWidget);
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
    await tester.tap(find.text('The Far Line'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap three pegs for the triangle'),
      findsOneWidget,
    );
  });

  testWidgets('a casting writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Far Line'));
    await tester.pumpAndSettle();
    await setPegs(tester, [(1, 0), (0, 1), (-1, -1)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:footbury/foot/levels.dart';

import 'support/fonts.dart';
import 'support/fieldland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Footbury'), findsOneWidget);
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
    await tester.tap(find.text('The Quarter'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap three rim pegs for the triangle'),
      findsOneWidget,
    );
  });

  testWidgets('a setting writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Quarter'));
    await tester.pumpAndSettle();
    await setPegs(tester, [(5, 0), (-4, 3), (-3, -4), (0, 0)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:evenmoor/moor/peggings.dart';

import 'support/fonts.dart';
import 'support/moorland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every pegging by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Evenmoor'), findsOneWidget);
    for (final pegging in Peggings.all) {
      expect(find.text(pegging.name), findsOneWidget);
      expect(
        find.textContaining(pegging.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a pegging opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four Apart'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap holes to set pegs'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four Apart'));
    await tester.pumpAndSettle();
    await setPegs(tester, [(0, 0), (1, 0), (0, 1), (1, 1)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}

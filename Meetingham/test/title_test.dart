import 'package:flutter_test/flutter_test.dart';
import 'package:meetingham/lane/levels.dart';

import 'support/fonts.dart';
import 'support/laneland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Meetingham'), findsOneWidget);
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
    await tester.tap(find.text('The Medians'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a post on a side to move that side\'s gate there'),
      findsOneWidget,
    );
  });

  testWidgets('a laning writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Medians'));
    await tester.pumpAndSettle();
    await setGates(tester, 6, 6, 6);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pursebury/duel/levels.dart';

import 'support/fonts.dart';
import 'support/duelland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Pursebury'), findsOneWidget);
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
      find.textContaining('Fill the purses a coin a tap, turn the coin over'),
      findsOneWidget,
    );
  });

  testWidgets('a duel writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Quarter'));
    await tester.pumpAndSettle();
    await setDuel(tester, 1, 3);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}

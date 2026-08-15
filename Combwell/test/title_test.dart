import 'package:flutter_test/flutter_test.dart';
import 'package:combwell/comb/levels.dart';

import 'support/fonts.dart';
import 'support/wellland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every supper by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Combwell'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a supper opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Last Four'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap an empty cell'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Last Four'));
    await tester.pumpAndSettle();
    await fill(tester, 8, 2);
    await fill(tester, 9, 5);
    await fill(tester, 10, 6);
    await fill(tester, 13, 4);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}

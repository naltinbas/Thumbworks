import 'package:flutter_test/flutter_test.dart';
import 'package:chordwell/chord/levels.dart';

import 'support/fonts.dart';
import 'support/chordland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Chordwell'), findsOneWidget);
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
    await tester.tap(find.text('The Nine'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap four pegs of the wheel, two for each chord'),
      findsOneWidget,
    );
  });

  testWidgets('a crossing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Nine'));
    await tester.pumpAndSettle();
    await setPegs(tester, [0, 6, 1, 11]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}

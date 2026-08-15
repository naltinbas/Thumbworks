import 'package:flutter_test/flutter_test.dart';
import 'package:cogsley/train/levels.dart';

import 'support/fonts.dart';
import 'support/trainland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every train by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Cogsley'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a train opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Idler'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Take a gear from the tray and tap a peg to set it there'),
      findsOneWidget,
    );
  });

  testWidgets('a gearing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Idler'));
    await tester.pumpAndSettle();
    await setGear(tester, 0, 3, 2);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}

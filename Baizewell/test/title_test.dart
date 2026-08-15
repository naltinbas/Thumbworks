import 'package:flutter_test/flutter_test.dart';
import 'package:baizewell/table/levels.dart';

import 'support/fonts.dart';
import 'support/tableland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every table by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Baizewell'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a table opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Far Pocket'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Set the sides, and the ball is shot from the home corner'),
      findsOneWidget,
    );
  });

  testWidgets('a setting writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Far Pocket'));
    await tester.pumpAndSettle();
    await set(tester, 'up+');
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}

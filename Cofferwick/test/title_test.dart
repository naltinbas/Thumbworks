import 'package:flutter_test/flutter_test.dart';
import 'package:cofferwick/coffer/levels.dart';

import 'support/fonts.dart';
import 'support/cofferland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Cofferwick'), findsOneWidget);
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
    await tester.tap(find.text('The Certain'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a coin to turn it, gold to silver or silver to gold'),
      findsOneWidget,
    );
  });

  testWidgets('a laying writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Certain'));
    await tester.pumpAndSettle();
    await lay(tester, [true, true, false, false, false, false]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}

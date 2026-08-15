import 'package:flutter_test/flutter_test.dart';
import 'package:cornerstow/yard/levels.dart';

import 'support/fonts.dart';
import 'support/yardland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every yard by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Cornerstow'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a yard opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Three'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Take a flag from the tray and tap the yard'),
      findsOneWidget,
    );
  });

  testWidgets('a paving writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Three'));
    await tester.pumpAndSettle();
    // The search's first paving: 1 at (0,0), 2 at (1,0), halves upright
    // at (0,1) and flat at (1,2).
    await lay(tester, 0, 0, 0);
    await lay(tester, 1, 1, 0);
    await lay(tester, 2, 0, 1, upright: true);
    await lay(tester, 2, 1, 2);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}

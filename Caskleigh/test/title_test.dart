import 'package:caskleigh/cask/levels.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/caskland.dart';
import 'support/fonts.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Caskleigh'), findsOneWidget);
    expect(
      find.textContaining(
          'the total is never a whole barrel, because one cask of the run '
          'has the most twos in it and no other does'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(find.textContaining(level.task.substring(1)), findsWidgets);
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('Past Two'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Move the ends of the run a cask a tap'),
      findsOneWidget,
    );
  });

  testWidgets('a run writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('Past One'));
    await tester.pumpAndSettle();
    await setRun(tester, 2, 4);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}

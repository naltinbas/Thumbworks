import 'package:flutter_test/flutter_test.dart';
import 'package:rimsbury/roll/levels.dart';

import 'support/fonts.dart';
import 'support/rollland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Rimsbury'), findsOneWidget);
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
    await tester.tap(find.text('The Twice'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Size the hoop and the roller a step a tap'),
      findsOneWidget,
    );
  });

  testWidgets('a roll writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Twice'));
    await tester.pumpAndSettle();
    await setCoins(tester, 3, 3);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}

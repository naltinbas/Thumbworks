import 'package:flutter_test/flutter_test.dart';
import 'package:knaveley/isle/levels.dart';

import 'support/fonts.dart';
import 'support/isleland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Knaveley'), findsOneWidget);
    expect(find.textContaining('Knights tell nothing but the truth'),
        findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tap a villager to call them a knight'),
        findsOneWidget);
  });

  testWidgets('a naming writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two'));
    await tester.pumpAndSettle();
    await nameAllByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}

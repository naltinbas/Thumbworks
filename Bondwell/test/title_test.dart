import 'package:flutter_test/flutter_test.dart';
import 'package:bondwell/bond/levels.dart';

import 'support/fonts.dart';
import 'support/bondland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Bondwell'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
    expect(find.textContaining('ivide 24 coins'), findsWidgets);
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Small Estate'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tap a purse to drop a coin in'), findsOneWidget);
  });

  testWidgets('a division writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Small Estate'));
    await tester.pumpAndSettle();
    await divideByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 6'), findsOneWidget);
  });
}

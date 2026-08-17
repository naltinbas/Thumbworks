import 'package:flutter_test/flutter_test.dart';
import 'package:leverstow/lever/levels.dart';

import 'support/fonts.dart';
import 'support/leverland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Leverstow'), findsOneWidget);
    expect(find.textContaining('Two levers, both fair on their own'),
        findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
    expect(find.textContaining('uild a loop whose purse climbs'), findsWidgets);
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Climb'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tap a slot to turn its lever over'),
        findsOneWidget);
  });

  testWidgets('a landing writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Climb'));
    await tester.pumpAndSettle();
    await loopByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:benchwood/bench/levels.dart';

import 'support/fonts.dart';
import 'support/benchland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Benchwood'), findsOneWidget);
    expect(find.textContaining('Carry back the tool whose next call is furthest off'),
        findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
    expect(find.textContaining('ork the card of 6 calls'), findsWidgets);
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Round'));
    await tester.pumpAndSettle();
    expect(find.textContaining('A tool on the bench is a free grab'),
        findsOneWidget);
  });

  testWidgets('a run writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Round'));
    await tester.pumpAndSettle();
    await workByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}

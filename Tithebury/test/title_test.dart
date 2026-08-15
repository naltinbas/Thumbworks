import 'package:flutter_test/flutter_test.dart';
import 'package:tithebury/tithe/levels.dart';

import 'support/fonts.dart';
import 'support/titheland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Tithebury'), findsOneWidget);
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
    await tester.tap(find.text('The Perfect'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Wind the number up or down, by one or by ten a tap'),
      findsOneWidget,
    );
  });

  testWidgets('a tally writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Perfect'));
    await tester.pumpAndSettle();
    await setNumber(tester, 6);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}

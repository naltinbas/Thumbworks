import 'package:flutter_test/flutter_test.dart';
import 'package:lotwick/ring/levels.dart';

import 'support/fonts.dart';
import 'support/ringland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Lotwick'), findsOneWidget);
    expect(
      find.textContaining(
          'no bid of yours earns more than bidding what the beast is worth'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(find.textContaining(level.task.substring(1)), findsWidgets);
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Windfall'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Set the three dials a crown a tap'),
      findsOneWidget,
    );
  });

  testWidgets('a setting writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Overbid Loss'));
    await tester.pumpAndSettle();
    await setDials(tester, 10, 12, 11);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shuntbury/yard/levels.dart';

import 'support/fonts.dart';
import 'support/yardland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Shuntbury'), findsOneWidget);
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
    await tester.tap(find.text('The Two Shunts'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a wagon beside the empty berth to shunt it in'),
      findsOneWidget,
    );
  });

  testWidgets('a shunting writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two Shunts'));
    await tester.pumpAndSettle();
    await shuntAll(tester, [5, 8]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}

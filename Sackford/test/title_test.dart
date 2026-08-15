import 'package:flutter_test/flutter_test.dart';
import 'package:sackford/yard/levels.dart';

import 'support/fonts.dart';
import 'support/yardland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every yard by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Sackford'), findsOneWidget);
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
    await tester.tap(find.text('The Two Carts'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a sack to move it to the next cart'),
      findsOneWidget,
    );
  });

  testWidgets('a loading writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two Carts'));
    await tester.pumpAndSettle();
    await load(tester, [0, 0, 1, 1, 1, 1]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 10'), findsOneWidget);
  });
}

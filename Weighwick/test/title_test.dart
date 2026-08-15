import 'package:flutter_test/flutter_test.dart';
import 'package:weighwick/scale/levels.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every load by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Weighwick'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a load opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a weight to move it'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two'));
    await tester.pumpAndSettle();
    await moveAll(tester, [1, 0, 0]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}

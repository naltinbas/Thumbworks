import 'package:flutter_test/flutter_test.dart';
import 'package:capwick/line/levels.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every line by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Capwick'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a line opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Three'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('You call for each man in turn'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Three'));
    await tester.pumpAndSettle();
    await callThePlan(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}

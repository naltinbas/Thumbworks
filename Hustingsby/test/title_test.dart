import 'package:flutter_test/flutter_test.dart';
import 'package:hustingsby/poll/levels.dart';

import 'support/fonts.dart';
import 'support/pollland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Hustingsby'), findsOneWidget);
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
    await tester.tap(find.text('The Clean Lead'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Draw the ballots from the box one at a time, Ash or Birch'),
      findsOneWidget,
    );
  });

  testWidgets('a count writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Clean Lead'));
    await tester.pumpAndSettle();
    await drawAll(tester, [true, true, true, false, false]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 5'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:oddrow/row/askings.dart';

import 'support/fonts.dart';
import 'support/wallland.dart';

/// The wall, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the wall lists every asking by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Oddrow'), findsOneWidget);
    for (final asking in Askings.all) {
      expect(find.text(asking.name), findsOneWidget);
      expect(
        find.textContaining(asking.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('an asking opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two Odds'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Wind the wall a row at a time'),
      findsOneWidget,
    );
  });

  testWidgets('a winding writes its fewest onto the wall',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two Odds'));
    await tester.pumpAndSettle();
    await press(tester, 'wind down');
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The wall');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}

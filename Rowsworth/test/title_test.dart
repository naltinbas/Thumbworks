import 'package:flutter_test/flutter_test.dart';
import 'package:rowsworth/pebble/askings.dart';

import 'support/fonts.dart';
import 'support/worthland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every asking by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Rowsworth'), findsOneWidget);
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
    await tester.tap(find.text('The Seven Rows'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a number to pick that heap'),
      findsOneWidget,
    );
  });

  testWidgets('a met asking writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Seven Rows'));
    await tester.pumpAndSettle();
    await tapNumber(tester, 64);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}

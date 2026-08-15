import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/fordland.dart';

/// One ask on the screen, the year set as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 2);
    expect(
      find.textContaining('set the year so it has exactly three Fridays the thirteenth'),
      findsOneWidget,
    );
    expect(find.text('Fridays 2'), findsOneWidget);
    expect(find.text('begins Monday'), findsOneWidget);
    expect(find.text('common'), findsOneWidget);
    expect(find.text('2 Fridays the thirteenth: April, July.'), findsOneWidget);
  });

  testWidgets('the day moves on, February changes, and back undoes', (tester) async {
    await open(tester, which: 2);
    await nextDay(tester);
    expect(find.text('begins Tuesday'), findsOneWidget);
    await toggleLeap(tester);
    expect(find.text('leap'), findsOneWidget);
    expect(find.text('Make it common'), findsOneWidget);
    await press(tester, 'Back');
    expect(find.text('common'), findsOneWidget);
    expect(state(tester).play.moves, 1);
  });

  testWidgets('three Fridays from a Thursday and the card shown', (tester) async {
    await open(tester, which: 2);
    await nextDay(tester);
    await nextDay(tester);
    await nextDay(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('As asked: 3 Fridays the thirteenth, February, March, November.'), findsOneWidget);
    expect(
      find.textContaining('A common year beginning on a Thursday: Friday the thirteenth in February, March, November; 3 taps.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me says February', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, 'leap');
    expect(find.text('Change the length of February.'), findsOneWidget);
  });

  testWidgets('show me says a day', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, 'day');
    expect(find.text('Move the first of January on a day.'), findsOneWidget);
  });

  testWidgets('the pointer sets a Friday in November', (tester) async {
    await open(tester, which: 3);
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.fridays, contains(10));
  });

  testWidgets('no Friday never comes', (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 14; k++) {
      if (k == 6) {
        await toggleLeap(tester);
      } else {
        await nextDay(tester);
      }
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Every year has its Friday.'), findsOneWidget);
    expect(
      find.textContaining('fall on all seven days of the week, whatever day the year begins'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the days along the week', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('0, 3, 3, 6, 1, 4, 6, 2, 5, 0, 3, 5 in a common year'),
      findsOneWidget,
    );
    expect(
      find.textContaining('No kind of year has no Friday the thirteenth'),
      findsOneWidget,
    );
  });

  testWidgets('the why of three Fridays counts the kinds', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('Of the fourteen kinds, 2 land this ask'),
      findsOneWidget,
    );
  });
}
